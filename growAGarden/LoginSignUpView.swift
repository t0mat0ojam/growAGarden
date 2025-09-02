import SwiftUI

struct LoginSignUpView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color(.systemMint).opacity(0.2), Color(.systemTeal).opacity(0.07)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 28) {
                    Spacer()

                    Text("Welcome to GrowAGarden")
                        .font(.system(size: 32, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 20)

                    TextField("Email", text: $email)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(Color(.systemGray6).opacity(0.96))
                        .cornerRadius(12)
                        .font(.system(size: 18, design: .rounded))

                    SecureField("Password", text: $password)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(Color(.systemGray6).opacity(0.96))
                        .cornerRadius(12)
                        .font(.system(size: 18, design: .rounded))

                    VStack(spacing: 16) {
                        // LOGIN BUTTON
                        Button(action: {
                            Task {
                                await login()
                            }
                        }) {
                            if isLoading {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue.opacity(0.7))
                                    .cornerRadius(15)
                            } else {
                                Text("Login")
                                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color(.systemBlue).opacity(0.75), Color.blue.opacity(0.85)]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .foregroundColor(.white)
                                    .cornerRadius(15)
                                    .shadow(color: Color(.systemBlue).opacity(0.15), radius: 6, x: 0, y: 3)
                            }
                        }

                        // SIGN UP BUTTON
                        Button(action: {
                            Task {
                                await signUp()
                            }
                        }) {
                            if isLoading {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green.opacity(0.7))
                                    .cornerRadius(15)
                            } else {
                                Text("Sign Up")
                                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color(.systemGreen).opacity(0.65), Color(.systemGreen).opacity(0.85)]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .foregroundColor(.white)
                                    .cornerRadius(15)
                                    .shadow(color: Color(.systemGreen).opacity(0.15), radius: 6, x: 0, y: 3)
                            }
                        }
                    }

                    Spacer()
                }
                .padding(.horizontal, 32)
            }
        }
    }

    // MARK: - Helper Methods
    @MainActor
    private func login() async {
        isLoading = true
        let success = await authManager.signIn(email: email, password: password)
        isLoading = false
        if !success {
            print("❌ Login failed")
        }
    }

    @MainActor
    private func signUp() async {
        isLoading = true
        let success = await authManager.signUp(email: email, password: password)
        isLoading = false
        if !success {
            print("❌ Sign-up failed")
        }
    }
}

struct LoginSignUpView_Previews: PreviewProvider {
    static var previews: some View {
        LoginSignUpView()
            .environmentObject(AuthManager.shared)
    }
}

