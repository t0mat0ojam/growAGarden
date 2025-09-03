import SwiftUI

// MARK: - DBHabit Model (unchanged)
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
    .init(id: "bike",    title: "Bike/public transportation rather than car", requiresTemperature: false),
    .init(id: "ac",      title: "Airconditioner only down to x degrees",      requiresTemperature: true),
    .init(id: "bottle",  title: "Use reusable waterbottle",                    requiresTemperature: false),
    .init(id: "lunch",   title: "Bring lunch rather than buy",                 requiresTemperature: false),
    .init(id: "hangdry", title: "Hang-dry laundry instead of using a dryer",  requiresTemperature: false)
]

// MARK: - ContentView
struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager

    // Personal (user-typed) habits loaded/saved via Supabase
    @State private var personalHabits: [DBHabit] = []
    @State private var newPersonalHabit: String = ""
    @State private var isSavingPersonal = false

    // Environmental selections (local UI state)
    @State private var selectedEnvIDs: Set<String> = []
    @State private var acTemp: Double = 26.5 // required when AC is selected

    // Navigation
    @State private var showNextPage: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    gradient: Gradient(colors: [Color(.systemMint).opacity(0.2),
                                                Color(.systemTeal).opacity(0.07)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 22) {
                        // Title
                        Text("Choose Your Habits")
                            .font(.system(size: 34, weight: .semibold, design: .rounded))
                            .padding(.top, 14)

                        // -------------------------------
                        // Environmental Habits (presets)
                        // -------------------------------
                        sectionCard(title: "Environmental Habits") {
                            VStack(spacing: 10) {
                                ForEach(ENV_OPTIONS) { opt in
                                    VStack(alignment: .leading, spacing: 10) {
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
                                                Text("Set temperature")
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
                                            .shadow(color: Color(.systemTeal).opacity(0.10), radius: 6, x: 0, y: 3)
                                    )
                                }
                            }
                        }

                        // -------------------------------
                        // Personal Habits (free text)
                        // -------------------------------
                        sectionCard(title: "Personal Habits") {
                            VStack(spacing: 10) {
                                HStack {
                                    TextField("Type a habit…", text: $newPersonalHabit)
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
                                    .disabled(newPersonalHabit.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSavingPersonal)
                                    .foregroundColor(Color(.systemMint))
                                }

                                if personalHabits.isEmpty {
                                    Text("No personal habits yet. Add one above 👆")
                                        .foregroundColor(.secondary)
                                        .font(.footnote)
                                        .padding(.top, 4)
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
                                                    await loadPersonalHabits()
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
                                        .shadow(color: Color(.systemTeal).opacity(0.10), radius: 6, x: 0, y: 3)
                                    }
                                }
                            }
                        }

                        // -------------------------------
                        // Go button
                        // -------------------------------
                        Button {
                            showNextPage = true
                        } label: {
                            Text("Go")
                                .font(.system(size: 22, weight: .semibold, design: .rounded))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color(.systemTeal).opacity(0.75),
                                                                    Color(.systemMint).opacity(0.8)]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .foregroundColor(.white)
                                .cornerRadius(16)
                                .shadow(color: Color(.systemTeal).opacity(0.12), radius: 8, x: 0, y: 3)
                        }
                        .padding(.horizontal, 40)
                        .padding(.bottom, 28)
                        .disabled(!canProceed)
                        .navigationDestination(isPresented: $showNextPage) {
                            NextPageView(habits: finalHabitNames) // NextPageView(habits: [String]) is what your file uses
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 10)
                }
            }
        }
        .task { await loadPersonalHabits() } // load on first appear
    }

    // MARK: - Derived data
    private var canProceed: Bool {
        // must have at least one selected/env or personal
        guard !(selectedEnvIDs.isEmpty && personalHabits.isEmpty) else { return false }
        // if AC selected, require a temperature within range
        if selectedEnvIDs.contains("ac") {
            return (18.0...30.0).contains(acTemp)
        }
        return true
    }

    private var finalHabitNames: [String] {
        let envNames: [String] = ENV_OPTIONS.compactMap { opt in
            guard selectedEnvIDs.contains(opt.id) else { return nil }
            if opt.id == "ac" {
                return "Airconditioner only down to \(String(format: "%.1f", acTemp))°C"
            } else {
                return opt.title
            }
        }

        // Personal habits are stored as DBHabit via Supabase
        let personal = personalHabits.map { $0.habit_name }

        // Deduplicate by name, keep order (environmental first, then personal)
        var seen = Set<String>()
        let combined = (envNames + personal).filter { seen.insert($0).inserted }
        return combined
    }

    // MARK: - Helpers
    @ViewBuilder
    private func sectionCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .padding(.horizontal, 6)

            content()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.75))
                .shadow(color: Color(.systemTeal).opacity(0.10), radius: 8, x: 0, y: 4)
        )
    }

    @MainActor
    private func loadPersonalHabits() async {
        guard authManager.isLoggedIn else { return }
        let fetched = await authManager.fetchHabits()
        personalHabits = fetched
    }

    @MainActor
    private func addPersonalHabit() async {
        let trimmed = newPersonalHabit.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        isSavingPersonal = true

        // optimistic local append
        personalHabits.append(DBHabit(id: UUID().uuidString, habit_name: trimmed))
        newPersonalHabit = ""

        // persist
        await authManager.saveHabit(name: trimmed)

        // reload from DB (authoritative source)
        await loadPersonalHabits()
        isSavingPersonal = false
    }
}

