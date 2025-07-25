import SwiftUI

struct MainAppView: View {
    // AuthManager is created here and passed down.
    // In growAGardenApp, we will also provide it as an EnvironmentObject
    // to ensure it's available throughout the app's hierarchy.
    @EnvironmentObject var authManager: AuthManager // Now receiving from environment

    var body: some View {
        Group {
            if authManager.isLoggedIn {
                // ContentView now also receives authManager from the environment
                ContentView()
            } else {
                // LoginSignUpView needs authManager to perform login/signup actions
                LoginSignUpView()
                    .environmentObject(authManager) // Explicitly pass to LoginSignUpView
            }
        }
    }
}
