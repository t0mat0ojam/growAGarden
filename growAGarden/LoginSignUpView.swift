import SwiftUI

struct LoginSignUpView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        ZStack {
            // Soft gradient background
            LinearGradient(
                gradient: Gradient(colors: [Color(.systemMint).opacity(0.2), Color(.systemTeal).opacity(0.07)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()

                // Welcome Title
                Text("Welcome to GrowAGarden")
                    .font(.system(size: 32, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 20)

                // Email Field
                TextField("Email", text: $email)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color(.systemGray6).opacity(0.96))
                    .cornerRadius(12)
                    .font(.system(size: 18, design: .rounded))

                // Password Field
                SecureField("Password", text: $password)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color(.systemGray6).opacity(0.96))
                    .cornerRadius(12)
                    .font(.system(size: 18, design: .rounded))

                VStack(spacing: 16) {
                    // Login Button
                    Button(action: {
                        authManager.isLoggedIn = true
                    }) {
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

                    // Sign Up Button
                    Button(action: {
                        authManager.isLoggedIn = true
                    }) {
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

                Spacer()
            }
            .padding(.horizontal, 32)
        }
    }
}

