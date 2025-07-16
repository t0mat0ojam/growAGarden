import SwiftUI

struct MainAppView: View {
    @StateObject var authManager = AuthManager()
    
    var body: some View {
        Group {
            if authManager.isLoggedIn {
                ContentView()
            } else {
                LoginSignUpView()
                    .environmentObject(authManager)
            }
        }
    }
}

