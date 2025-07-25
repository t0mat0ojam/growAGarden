import SwiftUI
import FirebaseAuth

struct LoginSignUpView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var email = ""
    @State private var password = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""

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

                // Display AuthManager messages
                if let msg = authManager.message, !msg.isEmpty {
                    Text(msg)
                        .foregroundColor(.red)
                        .font(.subheadline)
                        .padding(.horizontal)
                }

                // Email Field (kept for your original design, but not active for Firebase email/password yet)
                TextField("Email", text: $email)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color(.systemGray6).opacity(0.96))
                    .cornerRadius(12)
                    .font(.system(size: 18, design: .rounded))

                // Password Field (kept for your original design, but not active for Firebase email/password yet)
                SecureField("Password", text: $password)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color(.systemGray6).opacity(0.96))
                    .cornerRadius(12)
                    .font(.system(size: 18, design: .rounded))

                VStack(spacing: 16) {
                    // Login Button (will trigger anonymous sign-in for now)
                    Button(action: {
                        // In a real app, you'd call authManager.signIn(email: email, password: password) here
                        // For now, it will trigger the anonymous sign-in attempt from AuthManager
                        // The AuthManager's listener will then set isLoggedIn to true if successful.
                        if !authManager.isLoggedIn {
                            authManager.attemptSignIn() // Re-attempt anonymous/custom token sign-in
                        } else {
                            alertMessage = "You are already logged in."
                            showingAlert = true
                        }
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

                    // Sign Up Button (will trigger anonymous sign-in for now)
                    Button(action: {
                        // In a real app, you'd call authManager.signUp(email: email, password: password) here
                        // For now, it will trigger the anonymous sign-in attempt from AuthManager
                        if !authManager.isLoggedIn {
                            authManager.attemptSignIn() // Re-attempt anonymous/custom token sign-in
                        } else {
                            alertMessage = "You are already logged in."
                            showingAlert = true
                        }
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

                    // New: Continue Anonymously Button
                    Button(action: {
                        if !authManager.isLoggedIn {
                            authManager.signInAnonymously() // Explicitly call anonymous sign-in
                        } else {
                            alertMessage = "You are already logged in."
                            showingAlert = true
                        }
                    }) {
                        Text("Continue Anonymously")
                            .font(.system(size: 18, weight: .regular, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.primary)
                            .cornerRadius(15)
                            .shadow(color: Color.gray.opacity(0.1), radius: 3, x: 0, y: 2)
                    }
                }
                .padding(.horizontal, 32)
                
                Spacer()
            }
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Info"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
}
