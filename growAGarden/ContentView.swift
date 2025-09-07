import SwiftUI

// MARK: - DBHabit Model
struct DBHabit: Identifiable, Codable, Equatable {
    let id: String
    let habit_name: String
}

// MARK: - Environmental Presets
private struct EnvironmentalOption: Identifiable, Hashable {
    let id: String
    let title: String
    let requiresTemperature: Bool
}

private let ENV_OPTIONS: [EnvironmentalOption] = [
    .init(id: "bike",    title: "車ではなく自転車・公共交通機関を利用する", requiresTemperature: false),
    .init(id: "ac",      title: "エアコンは設定温度までに抑える",            requiresTemperature: true),
    .init(id: "bottle",  title: "マイボトルを使う",                          requiresTemperature: false),
    .init(id: "lunch",   title: "昼食は買わずに持参する",                    requiresTemperature: false),
    .init(id: "hangdry", title: "乾燥機ではなく自然乾燥をする",              requiresTemperature: false)
]

// MARK: - Helpers
private extension String {
    var trimmedOrNil: String? {
        let s = trimmingCharacters(in: .whitespacesAndNewlines)
        return s.isEmpty ? nil : s
    }
}
private extension Array where Element == DBHabit {
    mutating func mergeCaseInsensitive(_ incoming: [DBHabit]) {
        var seen = Set(self.map { $0.habit_name.lowercased() })
        for item in incoming {
            let key = item.habit_name.lowercased()
            if !seen.contains(key) {
                self.append(item)
                seen.insert(key)
            }
        }
    }
}

// MARK: - ContentView
struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager

    // Personal (user-typed) habits
    @State private var personalHabits: [DBHabit] = []
    @State private var newPersonalHabit: String = ""
    @State private var isSavingPersonal = false

    // Environmental selections
    @State private var selectedEnvIDs: Set<String> = []
    @State private var acTemp: Double = 26.5

    // Navigation
    @State private var showNextPage: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                ecoBackground

                ScrollView {
                    VStack(spacing: 28) {
                        headerTitle
                        environmentSection
                        personalSection
                        goButton
                    }
                    .padding(.horizontal, 18)
                }
            }
        }
        // Put the navigation destination on the stack (lighter for the type-checker)
        .navigationDestination(isPresented: $showNextPage) {
            NextPageView(habits: finalHabitNames)
        }
        .task { await initialFetchMerge() }
    }
}

// MARK: - Derived data
private extension ContentView {
    var canProceed: Bool {
        if selectedEnvIDs.isEmpty && personalHabits.isEmpty && newPersonalHabit.trimmedOrNil == nil { return false }
        if selectedEnvIDs.contains("ac") { return (18.0...30.0).contains(acTemp) }
        return true
    }

    // broken up so the compiler is fast & predictable
    var finalHabitNames: [String] {
        let envNames: [String] = ENV_OPTIONS.compactMap { opt in
            guard selectedEnvIDs.contains(opt.id) else { return nil }
            if opt.id == "ac" {
                return "エアコンは \(String(format: "%.1f", acTemp))℃ に設定"
            } else {
                return opt.title
            }
        }

        var names: [String] = envNames + personalHabits.map { $0.habit_name }
        if let typed = newPersonalHabit.trimmedOrNil { names.append(typed) }

        var seen = Set<String>()
        var unique: [String] = []
        unique.reserveCapacity(names.count)
        for n in names {
            let k = n.lowercased()
            if seen.insert(k).inserted { unique.append(n) }
        }
        return unique
    }
}

// MARK: - UI pieces (small subviews = faster type checking)
private extension ContentView {
    var ecoBackground: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(.systemGreen).opacity(0.05),
                Color(.systemMint).opacity(0.03)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    var headerTitle: some View {
        Text("🌿 習慣を選ぼう")
            .font(.system(size: 32, weight: .bold, design: .rounded))
            .padding(.top, 20)
    }

    var environmentSection: some View {
        sectionCard(title: "環境にやさしい習慣") {
            VStack(spacing: 14) {
                ForEach(ENV_OPTIONS) { opt in
                    VStack(alignment: .leading, spacing: 12) {
                        Toggle(isOn: Binding(
                            get: { selectedEnvIDs.contains(opt.id) },
                            set: { on in
                                if on { selectedEnvIDs.insert(opt.id) }
                                else  { selectedEnvIDs.remove(opt.id) }
                            }
                        )) {
                            Text(opt.title)
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                        }

                        if opt.id == "ac", selectedEnvIDs.contains("ac") {
                            HStack(spacing: 12) {
                                Image(systemName: "thermometer.sun")
                                Text("設定温度")
                                Spacer()
                                Stepper(value: $acTemp, in: 18...30, step: 0.5) {
                                    Text(String(format: "%.1f ℃", acTemp))
                                        .font(.system(size: 16, weight: .semibold))
                                }
                            }
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemGray6).opacity(0.95))
                            )
                        }
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.white.opacity(0.9))
                            .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
                    )
                }
            }
        }
    }

    var personalSection: some View {
        sectionCard(title: "自分の習慣") {
            VStack(spacing: 12) {
                HStack {
                    TextField("習慣を入力…", text: $newPersonalHabit)
                        .textInputAutocapitalization(.sentences)
                        .disableAutocorrection(false)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6).opacity(0.97))
                        )

                    Button {
                        Task { await addPersonalHabit() }
                    } label: {
                        if isSavingPersonal {
                            ProgressView().frame(width: 28, height: 28)
                        } else {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 28))
                        }
                    }
                    .disabled(newPersonalHabit.trimmedOrNil == nil || isSavingPersonal)
                    .foregroundColor(Color(.systemMint))
                }

                if personalHabits.isEmpty {
                    Text("まだ習慣がありません。上に入力して追加しましょう 👆")
                        .foregroundColor(.secondary)
                        .font(.footnote)
                        .padding(.top, 6)
                } else {
                    ForEach(personalHabits.indices, id: \.self) { i in
                        let h = personalHabits[i]
                        HStack {
                            Text(h.habit_name)
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                            Spacer()
                            Button {
                                Task {
                                    await authManager.deleteHabit(h)
                                    personalHabits.removeAll {
                                        $0.id == h.id || $0.habit_name.lowercased() == h.habit_name.lowercased()
                                    }
                                }
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundColor(.pink)
                            }
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 14).fill(Color.white.opacity(0.9))
                        )
                        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
                    }
                }
            }
        }
    }

    var goButton: some View {
        Button {
            Task {
                if let typed = newPersonalHabit.trimmedOrNil {
                    let new = DBHabit(id: UUID().uuidString, habit_name: typed)
                    if !personalHabits.contains(where: { $0.habit_name.lowercased() == typed.lowercased() }) {
                        personalHabits.append(new)
                    }
                    newPersonalHabit = ""
                    await authManager.saveHabit(name: typed)
                }
                showNextPage = true
            }
        } label: {
            Text("次へ")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .frame(maxWidth: .infinity)
                .padding()
        }
        .buttonStyle(PrimaryButtonStyle())
        .padding(.horizontal, 40)
        .padding(.bottom, 30)
        .disabled(!canProceed)
    }

    @ViewBuilder
    func sectionCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .padding(.horizontal, 6)
            content()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.8))
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
        )
    }
}

// MARK: - Data Helpers
private extension ContentView {
    @MainActor
    func initialFetchMerge() async {
        guard authManager.isLoggedIn else { return }
        let fetched = await authManager.fetchHabits()
        if !fetched.isEmpty { personalHabits.mergeCaseInsensitive(fetched) }
    }

    @MainActor
    func addPersonalHabit() async {
        guard let trimmed = newPersonalHabit.trimmedOrNil else { return }
        isSavingPersonal = true
        let local = DBHabit(id: UUID().uuidString, habit_name: trimmed)
        if !personalHabits.contains(where: { $0.habit_name.lowercased() == trimmed.lowercased() }) {
            personalHabits.append(local)
        }
        newPersonalHabit = ""
        await authManager.saveHabit(name: trimmed)
        if authManager.isLoggedIn {
            let fetched = await authManager.fetchHabits()
            if !fetched.isEmpty { personalHabits.mergeCaseInsensitive(fetched) }
        }
        isSavingPersonal = false
    }
}

