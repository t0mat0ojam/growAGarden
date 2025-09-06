import SwiftUI

struct LoginSignUpView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Eco-friendly gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(.systemGreen).opacity(0.05),
                        Color(.systemMint).opacity(0.03)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 28) {
                    Spacer()

                    // Header
                    VStack(spacing: 8) {
                        Text("🌱 GrowAGardenへようこそ")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)

                        Text("習慣を育てて、持続可能な自分に")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.bottom, 8)

                    // Input Fields inside card
                    VStack(spacing: 16) {
                        TextField("メールアドレス", text: $email)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(12)
                            .font(.system(size: 18, design: .rounded))

                        SecureField("パスワード", text: $password)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(12)
                            .font(.system(size: 18, design: .rounded))
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.85))
                            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                    )
                    .padding(.horizontal, 24)

                    // Buttons
                    VStack(spacing: 16) {
                        Button(action: {
                            Task { await login() }
                        }) {
                            if isLoading {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            } else {
                                Text("ログイン")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            }
                        }
                        .buttonStyle(PrimaryButtonStyle())

                        Button(action: {
                            Task { await signUp() }
                        }) {
                            if isLoading {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            } else {
                                Text("新規登録")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            }
                        }
                        .buttonStyle(SecondaryButtonStyle())
                    }
                    .padding(.horizontal, 24)

                    Spacer()
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }

    // MARK: - Helper Methods
    @MainActor
    private func login() async {
        isLoading = true
        let success = await authManager.signIn(email: email, password: password)
        isLoading = false
        if !success {
            print("❌ ログインに失敗しました")
        }
    }

    @MainActor
    private func signUp() async {
        isLoading = true
        let success = await authManager.signUp(email: email, password: password)
        isLoading = false
        if !success {
            print("❌ 新規登録に失敗しました")
        }
    }
}

struct LoginSignUpView_Previews: PreviewProvider {
    static var previews: some View {
        LoginSignUpView()
            .environmentObject(AuthManager.shared)
    }
}

