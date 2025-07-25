//
//  ContentView.swift
//  growAGardenApp
//
//  Created by YourName on 2023/01/01.
//

import SwiftUI

struct ContentView: View {
    // Access the shared FirebaseManager instance from the environment
    @EnvironmentObject var firebaseManager: FirebaseManager
    @EnvironmentObject var authManager: AuthManager // To display user ID

    @State private var newHabit: String = ""
    @State private var showNextPage: Bool = false
    @State private var showingMessageAlert: Bool = false // Controls alert presentation
    @State private var currentAlertMessage: String = "" // Message to display in the alert

    var body: some View {
        NavigationStack {
            ZStack {
                // Soft background color
                LinearGradient(gradient: Gradient(colors: [Color(.systemMint).opacity(0.2), Color(.systemTeal).opacity(0.07)]), startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                VStack {
                    Spacer()
                    
                    // Title centered with custom font
                    Text("Habits")
                        .font(.system(size: 38, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                        .padding(.bottom, 10)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)

                    // Display User ID
                    if let userId = authManager.userId {
                        Text("User ID: \(userId)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .padding(.horizontal)
                    }

                    // Display FirebaseManager messages
                    if let msg = firebaseManager.message, !msg.isEmpty && !showingMessageAlert {
                        Text(msg)
                            .foregroundColor(.blue)
                            .font(.subheadline)
                            .padding(.horizontal)
                    }
                    
                    // Habits list as soft rounded cards
                    // Now iterating over firebaseManager.habits
                    ForEach(firebaseManager.habits) { habit in
                        HStack {
                            Text(habit.name) // Display habit name from the Habit struct
                                .font(.system(size: 20, weight: .medium, design: .rounded))
                                .foregroundColor(.primary)
                                .padding(.vertical, 8)
                                .padding(.leading, 18)
                            
                            Spacer()
                            
                            // Delete button
                            Button(action: {
                                Task { // Use Task for async operation
                                    if let id = habit.id { // Ensure habit has an ID to delete
                                        await firebaseManager.deleteHabit(id: id)
                                        if let msg = firebaseManager.message {
                                            currentAlertMessage = msg
                                            showingMessageAlert = true
                                        }
                                    } else {
                                        currentAlertMessage = "Cannot delete habit: ID not found."
                                        showingMessageAlert = true
                                    }
                                }
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.pink)
                                    .padding(.trailing, 16)
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.white.opacity(0.86))
                                .shadow(color: Color(.systemTeal).opacity(0.12), radius: 8, x: 0, y: 4)
                        )
                        .padding(.horizontal, 20)
                        .padding(.vertical, 2)
                    }

                    // Habit input field
                    HStack {
                        TextField("Add new habit...", text: $newHabit)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemGray6).opacity(0.97))
                            )
                            .font(.system(size: 18, design: .rounded))
                        
                        Button(action: {
                            let trimmed = newHabit.trimmingCharacters(in: .whitespacesAndNewlines)
                            if !trimmed.isEmpty {
                                Task { // Use Task for async operation
                                    await firebaseManager.addHabit(name: trimmed)
                                    newHabit = "" // Clear the input field
                                    if let msg = firebaseManager.message {
                                        currentAlertMessage = msg
                                        showingMessageAlert = true
                                    }
                                }
                            } else {
                                currentAlertMessage = "Habit name cannot be empty."
                                showingMessageAlert = true
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(Color(.systemMint))
                                .font(.system(size: 28))
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 12)
                    
                    Spacer()
                    
                    // "Go" button
                    Button {
                        showNextPage = true
                    } label: {
                        Text("Go")
                            .font(.system(size: 22, weight: .semibold, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(gradient: Gradient(colors: [Color(.systemTeal).opacity(0.75), Color(.systemMint).opacity(0.8)]), startPoint: .leading, endPoint: .trailing)
                            )
                            .foregroundColor(.white)
                            .cornerRadius(15)
                            .shadow(color: Color(.systemTeal).opacity(0.12), radius: 8, x: 0, y: 3)
                    }
                    .padding(.horizontal, 48)
                    .padding(.bottom, 30)
                    .navigationDestination(isPresented: $showNextPage) {
                        // NextPageView will now also receive FirebaseManager from the environment
                        NextPageView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .alert(isPresented: $showingMessageAlert) {
            Alert(title: Text("Info"), message: Text(currentAlertMessage), dismissButton: .default(Text("OK")))
        }
    }
}
