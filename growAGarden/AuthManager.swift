import Foundation
import Supabase

@MainActor
class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    private let client: SupabaseClient
    
    @Published var session: Session?
    @Published var isLoggedIn = false // ❌ Start as false
    @Published var isLoading = true   // Track session loading
    
    init() {
        client = SupabaseClient(
            supabaseURL: URL(string: "https://rbkaimvqwcozaoswysdc.supabase.co")!,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJia2FpbXZxd2NvemFvc3d5c2RjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY3OTgxNTgsImV4cCI6MjA3MjM3NDE1OH0.sRsSKeDb23-A9SolOb6LbMeLVHnJYd3qT8ZUzgczrIE"
        )
        
        Task {
            await loadInitialSession()
        }
    }
    
    // MARK: - Session
    func loadInitialSession() async {
        do {
            let session = try await client.auth.session
            self.session = session
            // ❌ Do NOT set isLoggedIn automatically
        } catch {
            print("❌ Failed to load session:", error)
            self.session = nil
        }
        isLoading = false
    }
    
    // MARK: - Auth
    func signUp(email: String, password: String) async -> Bool {
        do {
            let _ = try await client.auth.signUp(email: email, password: password)
            return true
        } catch {
            print("❌ Sign-up error:", error)
            return false
        }
    }
    
    func signIn(email: String, password: String) async -> Bool {
        do {
            let _ = try await client.auth.signIn(email: email, password: password)
            self.isLoggedIn = true // ✅ Set only after manual login
            await loadInitialSession()
            return true
        } catch {
            print("❌ Sign-in error:", error)
            return false
        }
    }
    
    func signOut() async {
        do {
            try await client.auth.signOut()
            self.session = nil
            self.isLoggedIn = false
        } catch {
            print("❌ Sign-out error:", error)
        }
    }
    
    // MARK: - Habit CRUD
    
    func fetchHabits() async -> [DBHabit] {
        guard let userId = session?.user.id.uuidString else { return [] }

        do {
            let response = try await client
                .from("habits")
                .select()
                .eq("user_id", value: userId) // Only fetch current user's habits
                .execute()

            guard let data = response.data as? [[String: Any]] else { return [] }

            return data.compactMap { dict in
                guard let id = dict["id"] as? String,
                      let name = dict["habit_name"] as? String else { return nil }
                return DBHabit(id: id, habit_name: name)
            }
        } catch {
            print("❌ Failed to fetch habits:", error)
            return []
        }
    }
    
    struct NewHabit: Encodable {
        let habit_name: String
    }
    
    struct NewHabitWithUser: Encodable {
        let habit_name: String
        let user_id: String
    }

    func saveHabit(name: String) async {
        guard let userId = session?.user.id.uuidString else {
            print("❌ No logged-in user, cannot save habit")
            return
        }

        do {
            let newHabit = NewHabitWithUser(habit_name: name, user_id: userId)
            _ = try await client
                .from("habits")
                .insert(newHabit)
                .execute()
        } catch {
            print("❌ Failed to save habit:", error)
        }
    }
    func deleteHabit(_ habit: DBHabit) async {
        do {
            _ = try await client
                .from("habits")
                .delete()
                .eq("id", value: habit.id)
                .execute()
        } catch {
            print("❌ Failed to delete habit:", error)
        }
    }
}
