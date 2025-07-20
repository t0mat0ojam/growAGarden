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
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color("ParchmentTop"), Color("ParchmentBottom")]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Dear Journal,")
                                .font(.largeTitle)
                                .fontWeight(.semibold)

                            Text("Reflect, write, and grow a little each day.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)

                        // Emoji Picker
                        VStack(alignment: .leading, spacing: 10) {
                            Text("How are you feeling?")
                                .font(.headline)

                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 6), spacing: 12) {
                                ForEach(availableEmojis, id: \.self) { emoji in
                                    Button(action: {
                                        toggleEmoji(emoji)
                                    }) {
                                        Text(emoji)
                                            .font(.title2)
                                            .padding(8)
                                            .background(selectedEmojis.contains(emoji) ? Color.blue.opacity(0.3) : Color.white.opacity(0.7))
                                            .cornerRadius(8)
                                    }
                                    .disabled(!selectedEmojis.contains(emoji) && selectedEmojis.count >= 3)
                                }
                            }
                        }
                        .padding(.horizontal)

                        // Journal Entry
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Today's Entry")
                                .font(.title2)
                                .fontWeight(.medium)

                            TextEditor(text: $currentJournalText)
                                .frame(height: 150)
                                .padding()
                                .background(Color.white.opacity(0.85))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )

                            Button(action: saveJournalEntry) {
                                HStack {
                                    Image(systemName: "square.and.arrow.down")
                                    Text("Save Entry")
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(16)
                        .padding(.horizontal)

                        // Past Entries
                        if !journalEntries.isEmpty {
                            Text("Past Entries")
                                .font(.title2)
                                .fontWeight(.medium)
                                .padding(.horizontal)

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
                                            .font(.title2)
                                    }

                                    Text(entry.text)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                }
                                .padding()
                                .background(Color.white.opacity(0.85))
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
                                .padding(.horizontal)
                                .padding(.bottom, 5)
                            }
                        } else {
                            Text("No past entries yet. Start journaling!")
                                .foregroundColor(.secondary)
                                .padding()
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.top)
                }
            }
            .navigationTitle("Habit Grove")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear(perform: loadJournalEntries)
        }
    }

    // MARK: - Emoji Toggle
    private func toggleEmoji(_ emoji: String) {
        if let index = selectedEmojis.firstIndex(of: emoji) {
            selectedEmojis.remove(at: index)
        } else if selectedEmojis.count < 3 {
            selectedEmojis.append(emoji)
        }
    }

    // MARK: - Save / Load / Delete
    private func saveJournalEntry() {
        guard !currentJournalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            print("Journal entry is empty.")
            return
        }

        let newEntry = JournalEntry(date: Date(), text: currentJournalText, emojis: selectedEmojis)
        journalEntries.insert(newEntry, at: 0)
        currentJournalText = ""
        selectedEmojis = []
        saveJournalEntriesToUserDefaults()
    }

    private func loadJournalEntries() {
        if let savedEntriesData = UserDefaults.standard.data(forKey: journalEntriesKey) {
            do {
                let decodedEntries = try JSONDecoder().decode([JournalEntry].self, from: savedEntriesData)
                journalEntries = decodedEntries
            } catch {
                print("Error decoding journal entries: \(error.localizedDescription)")
            }
        }
    }

    private func saveJournalEntriesToUserDefaults() {
        do {
            let encodedEntries = try JSONEncoder().encode(journalEntries)
            UserDefaults.standard.set(encodedEntries, forKey: journalEntriesKey)
        } catch {
            print("Error encoding journal entries: \(error.localizedDescription)")
        }
    }

    private func deleteJournalEntry(at offsets: IndexSet) {
        journalEntries.remove(atOffsets: offsets)
        saveJournalEntriesToUserDefaults()
    }
}

struct JournalingView_Previews: PreviewProvider {
    static var previews: some View {
        JournalingView()
            .environment(\.colorScheme, .light)
    }
}

