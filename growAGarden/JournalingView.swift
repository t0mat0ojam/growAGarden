import SwiftUI

// MARK: - JournalEntry Model
// This struct represents a single journal entry, conforming to Codable
// so it can be easily saved to and loaded from UserDefaults.
struct JournalEntry: Identifiable, Codable {
    let id = UUID() // Unique identifier for each entry
    let date: Date // Timestamp when the entry was created
    var text: String // The actual journal text
}

// MARK: - JournalingView
// The main view for journaling, allowing users to write and view past entries.
struct JournalingView: View {
    // State variable to hold the current text being written in the TextEditor.
    // It's initialized as an empty string.
    @State private var currentJournalText: String = ""

    // State variable to hold all past journal entries.
    // It's initialized by loading existing entries from UserDefaults.
    @State private var journalEntries: [JournalEntry] = []

    // UserDefault key for storing journal entries.
    private let journalEntriesKey = "journalEntries"

    var body: some View {
        NavigationView { // Embed in NavigationView for title and potential future navigation
            VStack {
                Text("Journaling")
                    .font(.largeTitle)
                    .padding()

                Text("Here you will be able to write your thoughts and keep a habit journal.")
                    .font(.body)
                    .padding(.horizontal) // Add horizontal padding for better readability

                // MARK: - New Journal Entry Section
                // TextEditor for writing the current day's journal entry.
                TextEditor(text: $currentJournalText)
                    .frame(height: 150) // Give it a fixed height
                    .padding()
                    .background(Color.gray.opacity(0.1)) // Light gray background for the text box
                    .cornerRadius(10) // Rounded corners
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 1) // Thin gray border
                    )
                    .padding(.horizontal) // Padding around the text editor

                // Button to save the current journal entry.
                Button("Save Journal Entry") {
                    saveJournalEntry()
                }
                .padding()
                .background(Color.blue) // Blue background for the button
                .foregroundColor(.white) // White text color
                .cornerRadius(10) // Rounded corners for the button
                .padding(.bottom) // Padding below the button

                // MARK: - Past Journal Entries Section
                Text("Past Entries")
                    .font(.title2)
                    .padding(.top)

                // List to display all past journal entries.
                List {
                    // Check if there are any entries to display.
                    if journalEntries.isEmpty {
                        Text("No past entries yet. Start journaling!")
                            .foregroundColor(.gray)
                    } else {
                        // Iterate through the journalEntries array to display each entry.
                        ForEach(journalEntries.sorted(by: { $0.date > $1.date })) { entry in
                            VStack(alignment: .leading) {
                                // Display the date of the entry, formatted nicely.
                                Text(entry.date, style: .date)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text(entry.date, style: .time)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)

                                // Display the journal text.
                                Text(entry.text)
                                    .font(.body)
                                    .padding(.top, 2)
                                    .lineLimit(nil) // Allow text to wrap
                            }
                            .padding(.vertical, 5) // Vertical padding for each list item
                        }
                        // Add onDelete functionality to delete past entries.
                        .onDelete(perform: deleteJournalEntry)
                    }
                }
                .listStyle(.plain) // Use plain list style for a cleaner look
                .padding(.horizontal) // Padding around the list
            }
            .navigationTitle("Habit Grove") // Title for the navigation bar
            .navigationBarTitleDisplayMode(.inline) // Display title inline
            .onAppear(perform: loadJournalEntries) // Load entries when the view appears
        }
    }

    // MARK: - Helper Functions

    // Function to save the current journal entry.
    private func saveJournalEntry() {
        // Ensure the text box is not empty or just whitespace.
        guard !currentJournalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            // Optionally, show an alert to the user that the entry is empty.
            print("Journal entry is empty. Not saving.")
            return
        }

        // Create a new JournalEntry object with the current text and date.
        let newEntry = JournalEntry(date: Date(), text: currentJournalText)
        // Add the new entry to the beginning of the array so the latest is at the top.
        journalEntries.insert(newEntry, at: 0)
        // Clear the text editor after saving.
        currentJournalText = ""
        // Save the updated list of entries to UserDefaults.
        saveJournalEntriesToUserDefaults()
    }

    // Function to load journal entries from UserDefaults.
    private func loadJournalEntries() {
        if let savedEntriesData = UserDefaults.standard.data(forKey: journalEntriesKey) {
            do {
                // Decode the saved data into an array of JournalEntry objects.
                let decodedEntries = try JSONDecoder().decode([JournalEntry].self, from: savedEntriesData)
                journalEntries = decodedEntries
            } catch {
                print("Error decoding journal entries: \(error.localizedDescription)")
            }
        }
    }

    // Function to save the current list of journal entries to UserDefaults.
    private func saveJournalEntriesToUserDefaults() {
        do {
            // Encode the journalEntries array into Data.
            let encodedEntries = try JSONEncoder().encode(journalEntries)
            // Save the Data to UserDefaults.
            UserDefaults.standard.set(encodedEntries, forKey: journalEntriesKey)
        } catch {
            print("Error encoding journal entries: \(error.localizedDescription)")
        }
    }

    // Function to delete a journal entry from the list.
    private func deleteJournalEntry(at offsets: IndexSet) {
        // Remove the entry from the array.
        journalEntries.remove(atOffsets: offsets)
        // Save the updated list to UserDefaults after deletion.
        saveJournalEntriesToUserDefaults()
    }
}

// MARK: - Preview Provider
// Provides a preview of the JournalingView in Xcode's canvas.
struct JournalingView_Previews: PreviewProvider {
    static var previews: some View {
        JournalingView()
    }
}

