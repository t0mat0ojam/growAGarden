import SwiftUI

struct JournalEntry: Identifiable, Codable {
    let id = UUID()
    let date: Date
    var text: String
    var emojis: [String]
}

struct JournalingView: View {
    @State private var currentJournalText: String = ""
    @State private var journalEntries: [JournalEntry] = []
    @State private var selectedEmojis: [String] = []

    private let journalEntriesKey = "journalEntries"
    private let availableEmojis = ["😊", "😢", "🤬", "😤", "💩", "🔥", "💖", "🎯", "📚", "😴"]

    var body: some View {
        NavigationStack {
            ZStack {
                // Eco-friendly background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(.systemMint).opacity(0.2),
                        Color(.systemTeal).opacity(0.08)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        // Header
                        VStack(alignment: .leading, spacing: 6) {
                            Text("🌱 親愛なる日記へ")
                                .font(.system(size: 32, weight: .bold, design: .rounded))

                            Text("毎日ふりかえり、書いて、少しずつ成長しよう")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)

                        // ----------------------
                        // Emoji Picker
                        // ----------------------
                        sectionCard(title: "今の気分は？") {
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 6), spacing: 12) {
                                ForEach(availableEmojis, id: \.self) { emoji in
                                    Button(action: { toggleEmoji(emoji) }) {
                                        Text(emoji)
                                            .font(.title2)
                                            .padding(8)
                                            .frame(maxWidth: .infinity)
                                            .background(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .fill(selectedEmojis.contains(emoji) ?
                                                          Color(.systemTeal).opacity(0.25) :
                                                          Color.white.opacity(0.9))
                                            )
                                    }
                                    .disabled(!selectedEmojis.contains(emoji) && selectedEmojis.count >= 3)
                                }
                            }
                        }

                        // ----------------------
                        // Journal Entry
                        // ----------------------
                        sectionCard(title: "今日の記録") {
                            VStack(spacing: 12) {
                                TextEditor(text: $currentJournalText)
                                    .frame(height: 150)
                                    .padding()
                                    .background(Color.white.opacity(0.9))
                                    .cornerRadius(12)
                                    .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)

                                Button(action: saveJournalEntry) {
                                    HStack {
                                        Image(systemName: "square.and.arrow.down")
                                        Text("記録を保存")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                }
                                .buttonStyle(PrimaryButtonStyle())
                                .disabled(currentJournalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            }
                        }

                        // ----------------------
                        // Past Entries
                        // ----------------------
                        if !journalEntries.isEmpty {
                            sectionCard(title: "これまでの記録") {
                                VStack(spacing: 14) {
                                    ForEach(journalEntries.sorted(by: { $0.date > $1.date })) { entry in
                                        VStack(alignment: .leading, spacing: 6) {
                                            HStack {
                                                Text(entry.date, style: .date)
                                                    .font(.headline)
                                                Spacer()
                                                Text(entry.date, style: .time)
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                            }

                                            if !entry.emojis.isEmpty {
                                                Text(entry.emojis.joined(separator: " "))
                                                    .font(.title3)
                                            }

                                            Text(entry.text)
                                                .font(.body)
                                                .foregroundColor(.primary)
                                        }
                                        .padding()
                                        .background(Color.white.opacity(0.9))
                                        .cornerRadius(14)
                                        .shadow(color: Color(.systemTeal).opacity(0.1), radius: 6, x: 0, y: 3)
                                    }
                                }
                            }
                        } else {
                            Text("まだ記録がありません。今日から始めてみましょう！")
                                .foregroundColor(.secondary)
                                .padding()
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.top)
                }
            }
            .navigationTitle("ハビットグローブ")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear(perform: loadJournalEntries)
        }
    }

    // MARK: - Reusable section card
    @ViewBuilder
    private func sectionCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .padding(.horizontal, 6)

            content()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.75))
                .shadow(color: Color(.systemTeal).opacity(0.08), radius: 6, x: 0, y: 3)
        )
        .padding(.horizontal)
    }

    // MARK: - Emoji Toggle
    private func toggleEmoji(_ emoji: String) {
        if let index = selectedEmojis.firstIndex(of: emoji) {
            selectedEmojis.remove(at: index)
        } else if selectedEmojis.count < 3 {
            selectedEmojis.append(emoji)
        }
    }

    // MARK: - Save / Load
    private func saveJournalEntry() {
        guard !currentJournalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let newEntry = JournalEntry(date: Date(), text: currentJournalText, emojis: selectedEmojis)
        journalEntries.insert(newEntry, at: 0)
        currentJournalText = ""
        selectedEmojis = []
        saveJournalEntriesToUserDefaults()
    }

    private func loadJournalEntries() {
        if let savedEntriesData = UserDefaults.standard.data(forKey: journalEntriesKey) {
            if let decodedEntries = try? JSONDecoder().decode([JournalEntry].self, from: savedEntriesData) {
                journalEntries = decodedEntries
            }
        }
    }

    private func saveJournalEntriesToUserDefaults() {
        if let encodedEntries = try? JSONEncoder().encode(journalEntries) {
            UserDefaults.standard.set(encodedEntries, forKey: journalEntriesKey)
        }
    }
}

struct JournalingView_Previews: PreviewProvider {
    static var previews: some View {
        JournalingView()
            .environment(\.colorScheme, .light)
    }
}

