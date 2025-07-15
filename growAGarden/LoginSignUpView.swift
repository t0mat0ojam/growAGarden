import SwiftUI

struct LoginSignUpView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        VStack(spacing: 24) {
            Text("Welcome to GrowAGarden")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 40)

            TextField("Email", text: $email)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)

            SecureField("Password", text: $password)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)

            VStack(spacing: 12) {
                Button(action: {
                    // Normally, you would do validation/authentication here.
                    authManager.isLoggedIn = true
                }) {
                    Text("Login")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }

                Button(action: {
                    // Normally, you would do registration here.
                    authManager.isLoggedIn = true
                }) {
                    Text("Sign Up")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding(.top)

            Spacer()
        }
        .padding(.horizontal, 32)
    }
}


