import SwiftUI

struct SettingsView: View {
    var body: some View {
        VStack {
            Text("Settings")
                .font(.largeTitle)
                .padding()
            Text("Configure reminders, notifications, and your forest here.")
                .font(.body)
                .padding()
            Spacer()
        }
    }
}

