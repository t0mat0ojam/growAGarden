import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var showCustomizeView = false

    var body: some View {
        NavigationView {
            VStack {
                Text("Settings")
                    .font(.largeTitle)
                    .padding(.top, 10) // Adjusted top padding to move it further up
                    .padding(.bottom, 10)
                
                // "Change Habits" button
                Button(action: {
                    dismiss() // This will pop back to ContentView
                }) {
                    Text("Change Habits")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(14)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
                
                // "Customize" button
                Button(action: {
                    showCustomizeView = true
                }) {
                    Text("Customize")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.purple.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(14)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                
                Spacer()
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showCustomizeView) {
                CustomizeView()
            }
        }
    }
}

