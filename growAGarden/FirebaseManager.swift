import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth // Required for AuthManager's user ID
import FirebaseFirestoreSwift // For @DocumentID and Codable support
import Combine // For observing AuthManager
import SwiftUI // For @EnvironmentObject

// MARK: - Global Variables
// IMPORTANT: This should be defined ONLY ONCE in your project.
// We are keeping it here as it is used to build Firestore collection paths.
let __app_id: String = "com.tamonsasaki.HabitTracker"

// Manages all Firebase Firestore interactions for habits.
class FirebaseManager: ObservableObject {
    @Published var habits: [Habit] = []
    @Published var message: String?

    private var db: Firestore!
    private var habitsListener: ListenerRegistration?
    private var cancellables = Set<AnyCancellable>()

    // We will now receive the AuthManager as a parameter, not create a new one.
    // This allows FirebaseManager to observe the *shared* AuthManager instance.
    private var authManager: AuthManager

    init(authManager: AuthManager) {
        self.authManager = authManager
        // This is the standard way to configure Firebase
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        db = Firestore.firestore()
        setupAuthObservation()
    }

    // This is the code that will start and stop the listeners.
    func setupAuthObservation() {
        authManager.$userId
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newUserId in
                guard let self = self else { return }
                if let userId = newUserId {
                    print("FirebaseManager: AuthManager userId changed to \(userId). Starting habit listener.")
                    self.startListeningForHabits(userId: userId)
                } else {
                    print("FirebaseManager: AuthManager userId is nil. Stopping habit listener.")
                    self.stopListeningForHabits()
                }
            }
            .store(in: &cancellables)
    }

    /// Starts listening for real-time updates to the user's habits in Firestore.
    private func startListeningForHabits(userId: String) {
        habitsListener?.remove()

        let collectionPath = "artifacts/\(__app_id)/users/\(userId)/habits"
        habitsListener = db.collection(collectionPath)
            .addSnapshotListener { [weak self] (querySnapshot, error) in
                guard let self = self else { return }
                if let error = error {
                    print("Error fetching habits: \(error.localizedDescription)")
                    self.message = "Error loading habits: \(error.localizedDescription)"
                    return
                }

                guard let documents = querySnapshot?.documents else {
                    print("No habit documents found.")
                    self.habits = []
                    return
                }

                self.habits = documents.compactMap { doc -> Habit? in
                    do {
                        return try doc.data(as: Habit.self)
                    } catch {
                        print("Error decoding habit document: \(error.localizedDescription)")
                        return nil
                    }
                }
                print("Habits updated: \(self.habits.count) habits loaded.")
            }
    }

    /// Stops the Firestore listener for habits.
    private func stopListeningForHabits() {
        habitsListener?.remove()
        habitsListener = nil
        self.habits = []
    }

    /// Adds a new habit to Firestore.
    func addHabit(name: String, userId: String) async {
        let collectionPath = "artifacts/\(__app_id)/users/\(userId)/habits"
        do {
            _ = try await db.collection(collectionPath).addDocument(data: ["name": name, "completions": [:]])
            message = "Habit added successfully!"
            print("Habit '\(name)' added.")
        } catch {
            print("Error adding habit: \(error.localizedDescription)")
            message = "Error adding habit: \(error.localizedDescription)"
        }
    }

    /// Deletes a habit from Firestore.
    func deleteHabit(id: String, userId: String) async {
        let docPath = "artifacts/\(__app_id)/users/\(userId)/habits/\(id)"
        do {
            try await db.document(docPath).delete()
            message = "Habit deleted successfully!"
            print("Habit with ID \(id) deleted.")
        } catch {
            print("Error deleting habit: \(error.localizedDescription)")
            message = "Error deleting habit: \(error.localizedDescription)"
        }
    }

    /// Marks a habit as completed or skipped for the current day.
    func markHabitCompletion(habitId: String, completed: Bool, userId: String) async {
        let today = DateFormatter.yyyyMMdd.string(from: Date())
        let docPath = "artifacts/\(__app_id)/users/\(userId)/habits/\(habitId)"
        let habitRef = db.document(docPath)

        do {
            try await habitRef.updateData(["completions.\(today)": completed])
            message = "Habit status updated for \(today)!"
            print("Habit \(habitId) marked as \(completed ? "completed" : "skipped") for \(today).")
        } catch {
            print("Error updating habit completion: \(error.localizedDescription)")
            message = "Error updating habit status: \(error.localizedDescription)"
        }
    }
}

// MARK: - Date Formatter Extension
extension DateFormatter {
    static let yyyyMMdd: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone.current
        return formatter
    }()
}
