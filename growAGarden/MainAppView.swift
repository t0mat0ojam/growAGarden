import SwiftUI

struct MainAppView: View {
    @StateObject var authManager = AuthManager()
    @State private var isLoading = true
    
    var body: some View {
        Group {
            if isLoading {
                LoadingView()
                    .onAppear {
                        // Simulate loading time
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                            withAnimation(.easeInOut(duration: 0.8)) {
                                isLoading = false
                            }
                        }
                    }
            } else if authManager.isLoggedIn {
                ContentView()
                    .transition(.opacity)
            } else {
                LoginSignUpView()
                    .environmentObject(authManager)
                    .transition(.opacity)
            }
        }
    }
}
