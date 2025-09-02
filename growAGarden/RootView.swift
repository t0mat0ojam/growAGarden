import SwiftUI

struct RootView: View {
    @EnvironmentObject var authManager: AuthManager

    var body: some View {
        Group {
            if authManager.isLoading {
                ProgressView("Loading...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemBackground))
            } else {
                if authManager.isLoggedIn {
                    ContentView()
                } else {
                    LoginSignUpView()
                }
            }
        }
        .animation(.easeInOut, value: authManager.isLoggedIn)
        .animation(.easeInOut, value: authManager.isLoading)
    }
}

