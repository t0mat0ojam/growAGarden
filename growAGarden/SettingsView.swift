import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthManager
    
    @State private var showCustomizeView = false
    @State private var showAccountView = false
    @State private var showDataExportSheet = false
    @State private var showDeleteConfirmation = false
    
    // Settings States
    @AppStorage("enableNotifications") private var enableNotifications: Bool = true
    @AppStorage("darkModeEnabled") private var darkModeEnabled: Bool = false
    @AppStorage("soundEnabled") private var soundEnabled: Bool = true
    @AppStorage("hapticFeedback") private var hapticFeedback: Bool = true
    @AppStorage("weekStartsOnMonday") private var weekStartsOnMonday: Bool = true
    @AppStorage("enableStreakFreeze") private var enableStreakFreeze: Bool = false
    
    @State private var notificationTime: Date = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()

    var body: some View {
        NavigationView {
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

                ScrollView {
                    VStack(spacing: 0) {
                        // Header
                        VStack(spacing: 8) {
                            Text("🌱 Settings")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Text("Customize your sustainable journey")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 24)
                        
                        // Settings Sections
                        VStack(spacing: 24) {
                            // Habits Section
                            SettingsSection(title: "🌿 Your Habits", icon: "leaf.fill") {
                                SettingsRow(
                                    title: "Manage Habits",
                                    subtitle: "Add, edit, or remove habits",
                                    icon: "pencil.circle.fill",
                                    action: { dismiss() }
                                )
                                
                                SettingsRow(
                                    title: "Habit Categories",
                                    subtitle: "Organize by environmental impact",
                                    icon: "folder.fill",
                                    action: { showCustomizeView = true }
                                )
                            }
                            
                            // Notifications Section
                            SettingsSection(title: "🔔 Reminders", icon: "bell.fill") {
                                SettingsToggleRow(
                                    title: "Daily Reminders",
                                    subtitle: "Get notified to check in",
                                    icon: "bell.circle.fill",
                                    isOn: $enableNotifications
                                )
                                
                                if enableNotifications {
                                    SettingsRow(
                                        title: "Reminder Time",
                                        subtitle: notificationTime.formatted(date: .omitted, time: .shortened),
                                        icon: "clock.fill",
                                        action: { /* Open time picker */ }
                                    )
                                }
                                
                                SettingsToggleRow(
                                    title: "Streak Freeze",
                                    subtitle: "Skip days without breaking streaks",
                                    icon: "snowflake",
                                    isOn: $enableStreakFreeze
                                )
                            }
                            
                            // Appearance Section
                            SettingsSection(title: "🎨 Appearance", icon: "paintbrush.fill") {
                                SettingsToggleRow(
                                    title: "Dark Mode",
                                    subtitle: "Reduce energy consumption",
                                    icon: "moon.fill",
                                    isOn: $darkModeEnabled
                                )
                                
                                SettingsRow(
                                    title: "Customize Garden",
                                    subtitle: "Personalize your forest view",
                                    icon: "tree.fill",
                                    action: { showCustomizeView = true }
                                )
                                
                                SettingsToggleRow(
                                    title: "Week Starts on Monday",
                                    subtitle: "Calendar and stats preference",
                                    icon: "calendar",
                                    isOn: $weekStartsOnMonday
                                )
                            }
                            
                            // Experience Section
                            SettingsSection(title: "🎯 Experience", icon: "target") {
                                SettingsToggleRow(
                                    title: "Sound Effects",
                                    subtitle: "Audio feedback for actions",
                                    icon: "speaker.wave.2.fill",
                                    isOn: $soundEnabled
                                )
                                
                                SettingsToggleRow(
                                    title: "Haptic Feedback",
                                    subtitle: "Vibration for interactions",
                                    icon: "iphone.radiowaves.left.and.right",
                                    isOn: $hapticFeedback
                                )
                            }
                            
                            // Data & Privacy Section
                            SettingsSection(title: "📊 Data & Privacy", icon: "shield.fill") {
                                SettingsRow(
                                    title: "Export Data",
                                    subtitle: "Download your progress",
                                    icon: "square.and.arrow.up.fill",
                                    action: { showDataExportSheet = true }
                                )
                                
                                SettingsRow(
                                    title: "Privacy Policy",
                                    subtitle: "How we protect your data",
                                    icon: "hand.raised.fill",
                                    action: { /* Open privacy policy */ }
                                )
                                
                                SettingsRow(
                                    title: "Delete All Data",
                                    subtitle: "Permanently remove your progress",
                                    icon: "trash.fill",
                                    textColor: .red,
                                    action: { showDeleteConfirmation = true }
                                )
                            }
                            
                            // About Section
                            SettingsSection(title: "ℹ️ About", icon: "info.circle.fill") {
                                SettingsRow(
                                    title: "Version",
                                    subtitle: "1.0.0",
                                    icon: "app.badge.fill",
                                    action: { }
                                )
                                
                                SettingsRow(
                                    title: "Environmental Impact",
                                    subtitle: "Learn about our mission",
                                    icon: "globe.americas.fill",
                                    action: { /* Open impact info */ }
                                )
                                
                                SettingsRow(
                                    title: "Rate on App Store",
                                    subtitle: "Help us grow sustainably",
                                    icon: "star.fill",
                                    action: { /* Open App Store */ }
                                )
                                
                                SettingsRow(
                                    title: "Contact Support",
                                    subtitle: "We're here to help",
                                    icon: "envelope.fill",
                                    action: { /* Open email */ }
                                )
                            }
                            
                            // Account Section
                            SettingsSection(title: "👤 Account", icon: "person.fill") {
                                SettingsRow(
                                    title: "Account Settings",
                                    subtitle: "Manage your profile",
                                    icon: "person.circle.fill",
                                    action: { showAccountView = true }
                                )
                                
                                SettingsRow(
                                    title: "Sign Out",
                                    subtitle: "We'll miss you!",
                                    icon: "rectangle.portrait.and.arrow.right.fill",
                                    textColor: .red,
                                    action: { authManager.isLoggedIn = false }
                                )
                            }
                        }
                        .padding(.bottom, 32)
                    }
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .sheet(isPresented: $showCustomizeView) {
                CustomizeView()
            }
            .sheet(isPresented: $showAccountView) {
                AccountView()
            }
            .sheet(isPresented: $showDataExportSheet) {
                DataExportView()
            }
            .confirmationDialog("Delete All Data", isPresented: $showDeleteConfirmation) {
                Button("Delete Everything", role: .destructive) {
                    deleteAllData()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This will permanently delete all your habits, progress, and journal entries. This action cannot be undone.")
            }
        }
    }
    
    private func deleteAllData() {
        // Clear UserDefaults
        let keys = ["journalEntries", "habitProgress", "plantStates"]
        keys.forEach { UserDefaults.standard.removeObject(forKey: $0) }
        
        // Reset app state
        // You'd implement this based on your data architecture
    }
}

// MARK: - Settings Components

struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(.green)
                    .font(.title3)
                
                Text(title)
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            
            VStack(spacing: 1) {
                content()
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.85))
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
            )
            .padding(.horizontal, 16)
        }
    }
}

struct SettingsRow: View {
    let title: String
    let subtitle: String
    let icon: String
    var textColor: Color = .primary
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .foregroundColor(.green)
                    .font(.title3)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(textColor)
                        .multilineTextAlignment(.leading)
                    
                    Text(subtitle)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SettingsToggleRow: View {
    let title: String
    let subtitle: String
    let icon: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(.green)
                .font(.title3)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                Text(subtitle)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: .green))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }
}

// MARK: - Additional Views

struct AccountView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Profile Section
                VStack(spacing: 16) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.green)
                    
                    Text("Eco Warrior")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Growing a sustainable future")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 32)
                
                // Account Stats
                VStack(spacing: 16) {
                    HStack {
                        AccountStatCard(title: "Days Active", value: "47", icon: "calendar.circle.fill")
                        AccountStatCard(title: "Trees Grown", value: "23", icon: "tree.circle.fill")
                    }
                    
                    HStack {
                        AccountStatCard(title: "CO₂ Saved", value: "156kg", icon: "leaf.circle.fill")
                        AccountStatCard(title: "Streak Record", value: "12", icon: "flame.circle.fill")
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button("Edit Profile") {
                        // Edit profile action
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    
                    Button("Change Password") {
                        // Change password action
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
            .navigationTitle("Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct AccountStatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.green)
                .font(.title2)
            
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.7))
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
}

struct DataExportView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("📊 Export Your Data")
                    .font(.title)
                    .fontWeight(.semibold)
                    .padding(.top, 32)
                
                Text("Download your habit tracking data and environmental impact statistics.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                VStack(spacing: 16) {
                    ExportOption(
                        title: "Habit Progress",
                        description: "All your habit completions and streaks",
                        format: "CSV"
                    )
                    
                    ExportOption(
                        title: "Environmental Impact",
                        description: "CO₂, water, and waste savings data",
                        format: "PDF"
                    )
                    
                    ExportOption(
                        title: "Journal Entries",
                        description: "Your reflection and mood data",
                        format: "JSON"
                    )
                    
                    ExportOption(
                        title: "Complete Data",
                        description: "Everything in one package",
                        format: "ZIP"
                    )
                }
                .padding(.horizontal)
                
                Spacer()
                
                Button("Export All Data") {
                    // Export functionality
                    dismiss()
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
            .navigationTitle("Export Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ExportOption: View {
    let title: String
    let description: String
    let format: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "doc.fill")
                .foregroundColor(.blue)
                .font(.title2)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(format)
                .font(.system(size: 12, weight: .semibold))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.1))
                .foregroundColor(.blue)
                .cornerRadius(6)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.7))
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Button Styles

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold, design: .rounded))
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.green.opacity(0.8), Color.mint.opacity(0.9)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundColor(.white)
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .medium, design: .rounded))
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.gray.opacity(0.1))
            .foregroundColor(.primary)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Preview
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(AuthManager())
    }
}
