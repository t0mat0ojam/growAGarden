import SwiftUI
import Firebase

@main
struct growAGardenApp: App {
    // Create a single instance of AuthManager
    @StateObject var authManager = AuthManager()
    
    // Create a single instance of FirebaseManager, passing the shared AuthManager instance to it.
    // This is the correct way to share state between them.
    @StateObject var firebaseManager: FirebaseManager

    init() {
        // This is the standard way to configure Firebase
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        // Initialize FirebaseManager with the created AuthManager instance
        _firebaseManager = StateObject(wrappedValue: FirebaseManager(authManager: self.authManager))
    }

    var body: some Scene {
        WindowGroup {
            // Your main app view, receiving FirebaseManager as an environment object.
            // This ensures FirebaseManager starts listening for habits
            // once AuthManager is ready and provides a userId.
            ContentView()
                .environmentObject(authManager)
                .environmentObject(firebaseManager)
        }
    }
}
