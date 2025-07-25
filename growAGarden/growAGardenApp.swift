//
//  growAGardenApp.swift
//  growAGardenApp
//
//  Created by YourName on 2023/01/01.
//

import SwiftUI
import Firebase // Import Firebase for initialization

@main
struct growAGardenApp: App {
    // Create a single instance of FirebaseManager to be shared across the app
    // This will handle Firebase initialization and data fetching.
    @StateObject var authManager = AuthManager()
    @StateObject var firebaseManager = FirebaseManager()

    // No init() needed here for FirebaseApp.configure()
    // as it's handled within the FirebaseManager's init() now.

    var body: some Scene {
        WindowGroup {
            // Your main app view, now receiving FirebaseManager as an environment object.
            MainAppView()
                .environmentObject(authManager) // Provide AuthManager to the environment
                .environmentObject(firebaseManager) // Make FirebaseManager available to all child views
                .onAppear {
                    // This ensures FirebaseManager starts listening for habits
                    // once AuthManager is ready and provides a userId.
                    firebaseManager.setupAuthObservation(authManager: authManager)
                }
        }
    }
}


