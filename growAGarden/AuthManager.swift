//
//  AuthManager.swift
//  growAGardenApp
//
//  Created by YourName on 2023/01/01.
//

import Foundation
import Combine
import Firebase
import FirebaseAuth

/// Manages Firebase authentication state for the application.
class AuthManager: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var userId: String? = nil
    @Published var message: String?

    private var auth: Auth!

    init() {
        // We configure Firebase here only if it hasn't been configured by
        // a different part of the app yet. This is the correct, standard approach.
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        
        auth = Auth.auth()
        setupAuthListener()
    }

    /// Sets up a listener for Firebase authentication state changes.
    private func setupAuthListener() {
        auth.addStateDidChangeListener { [weak self] (auth, user) in
            guard let self = self else { return }
            if let user = user {
                self.userId = user.uid
                self.isLoggedIn = true
                print("AuthManager: User authenticated: \(user.uid)")
            } else {
                self.userId = nil
                self.isLoggedIn = false
                print("AuthManager: User not authenticated.")
                // We call attemptSignIn() here, but the method needs to be
                // part of the AuthManager itself.
                self.attemptSignIn()
            }
        }
    }

    /// Attempts to sign in the user using a custom token or anonymously.
    // Making this internal so it can be called from LoginSignUpView.
    func attemptSignIn() {
        auth.signInAnonymously { [weak self] (authResult, error) in
            guard let self = self else { return }
            if let error = error {
                print("AuthManager: Error signing in anonymously: \(error.localizedDescription)")
                self.message = "Anonymous authentication failed: \(error.localizedDescription)"
            } else if let uid = authResult?.user.uid {
                self.userId = uid
                self.isLoggedIn = true
                print("AuthManager: Signed in anonymously: \(uid)")
            }
        }
    }

    /// Attempts to sign in the user anonymously.
    internal func signInAnonymously() {
        auth.signInAnonymously { [weak self] (authResult, error) in
            guard let self = self else { return }
            if let error = error {
                print("AuthManager: Error signing in anonymously: \(error.localizedDescription)")
                self.message = "Anonymous authentication failed: \(error.localizedDescription)"
            } else if let uid = authResult?.user.uid {
                self.userId = uid
                self.isLoggedIn = true
                print("AuthManager: Signed in anonymously: \(uid)")
            }
        }
    }

    // You can add signOut() method here if needed
    func signOut() {
        do {
            try auth.signOut()
            print("AuthManager: User signed out.")
            self.message = "Signed out successfully."
        } catch let signOutError as NSError {
            print("AuthManager: Error signing out: \(signOutError.localizedDescription)")
            self.message = "Error signing out: \(signOutError.localizedDescription)"
        }
    }
}
