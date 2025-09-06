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
                            Text("🌱 設定")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Text("サステナブルな旅を自分らしくカスタマイズ")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 24)
                        
                        // Settings Sections
                        VStack(spacing: 24) {
                            // Habits Section
                            SettingsSection(title: "🌿 習慣", icon: "leaf.fill") {
                                SettingsRow(
                                    title: "習慣を管理",
                                    subtitle: "追加・編集・削除",
                                    icon: "pencil.circle.fill",
                                    action: { dismiss() }
                                )
                                
                                SettingsRow(
                                    title: "習慣カテゴリ",
                                    subtitle: "環境への影響で整理",
                                    icon: "folder.fill",
                                    action: { showCustomizeView = true }
                                )
                            }
                            
                            // Notifications Section
                            SettingsSection(title: "🔔 リマインダー", icon: "bell.fill") {
                                SettingsToggleRow(
                                    title: "毎日のリマインダー",
                                    subtitle: "習慣を記録する通知",
                                    icon: "bell.circle.fill",
                                    isOn: $enableNotifications
                                )
                                
                                if enableNotifications {
                                    SettingsRow(
                                        title: "通知時間",
                                        subtitle: notificationTime.formatted(date: .omitted, time: .shortened),
                                        icon: "clock.fill",
                                        action: { /* Open time picker */ }
                                    )
                                }
                                
                                SettingsToggleRow(
                                    title: "ストリーク凍結",
                                    subtitle: "スキップしても継続記録が途切れない",
                                    icon: "snowflake",
                                    isOn: $enableStreakFreeze
                                )
                            }
                            
                            // Appearance Section
                            SettingsSection(title: "🎨 外観", icon: "paintbrush.fill") {
                                SettingsToggleRow(
                                    title: "ダークモード",
                                    subtitle: "省エネにもつながります",
                                    icon: "moon.fill",
                                    isOn: $darkModeEnabled
                                )
                                
                                SettingsRow(
                                    title: "庭をカスタマイズ",
                                    subtitle: "自分だけの森をデザイン",
                                    icon: "tree.fill",
                                    action: { showCustomizeView = true }
                                )
                                
                                SettingsToggleRow(
                                    title: "週の開始を月曜日にする",
                                    subtitle: "カレンダーと統計の設定",
                                    icon: "calendar",
                                    isOn: $weekStartsOnMonday
                                )
                            }
                            
                            // Experience Section
                            SettingsSection(title: "🎯 体験", icon: "target") {
                                SettingsToggleRow(
                                    title: "効果音",
                                    subtitle: "行動に音でフィードバック",
                                    icon: "speaker.wave.2.fill",
                                    isOn: $soundEnabled
                                )
                                
                                SettingsToggleRow(
                                    title: "触覚フィードバック",
                                    subtitle: "操作時にバイブレーション",
                                    icon: "iphone.radiowaves.left.and.right",
                                    isOn: $hapticFeedback
                                )
                            }
                            
                            // Data & Privacy Section
                            SettingsSection(title: "📊 データとプライバシー", icon: "shield.fill") {
                                SettingsRow(
                                    title: "データをエクスポート",
                                    subtitle: "習慣や統計をダウンロード",
                                    icon: "square.and.arrow.up.fill",
                                    action: { showDataExportSheet = true }
                                )
                                
                                SettingsRow(
                                    title: "プライバシーポリシー",
                                    subtitle: "データの扱いについて",
                                    icon: "hand.raised.fill",
                                    action: { /* Open privacy policy */ }
                                )
                                
                                SettingsRow(
                                    title: "すべてのデータを削除",
                                    subtitle: "習慣や進捗を完全に消去",
                                    icon: "trash.fill",
                                    textColor: .red,
                                    action: { showDeleteConfirmation = true }
                                )
                            }
                            
                            // About Section
                            SettingsSection(title: "ℹ️ アプリ情報", icon: "info.circle.fill") {
                                SettingsRow(
                                    title: "バージョン",
                                    subtitle: "1.0.0",
                                    icon: "app.badge.fill",
                                    action: { }
                                )
                                
                                SettingsRow(
                                    title: "環境への貢献について",
                                    subtitle: "私たちのミッションを見る",
                                    icon: "globe.americas.fill",
                                    action: { /* Open impact info */ }
                                )
                                
                                SettingsRow(
                                    title: "App Storeで評価",
                                    subtitle: "応援していただけると嬉しいです",
                                    icon: "star.fill",
                                    action: { /* Open App Store */ }
                                )
                                
                                SettingsRow(
                                    title: "サポートに連絡",
                                    subtitle: "ご不明点はお気軽に",
                                    icon: "envelope.fill",
                                    action: { /* Open email */ }
                                )
                            }
                            
                            // Account Section
                            SettingsSection(title: "👤 アカウント", icon: "person.fill") {
                                SettingsRow(
                                    title: "アカウント設定",
                                    subtitle: "プロフィールを管理",
                                    icon: "person.circle.fill",
                                    action: { showAccountView = true }
                                )
                                
                                SettingsRow(
                                    title: "サインアウト",
                                    subtitle: "またお会いできる日を楽しみにしています！",
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
            .confirmationDialog("すべてのデータを削除", isPresented: $showDeleteConfirmation) {
                Button("完全に削除", role: .destructive) {
                    deleteAllData()
                }
                Button("キャンセル", role: .cancel) { }
            } message: {
                Text("習慣、進捗、日記をすべて完全に削除します。この操作は元に戻せません。")
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
                    
                    Text("エコウォリアー")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("持続可能な未来を育てる")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 32)
                
                // Account Stats
                VStack(spacing: 16) {
                    HStack {
                        AccountStatCard(title: "稼働日数", value: "47", icon: "calendar.circle.fill")
                        AccountStatCard(title: "育った木の数", value: "23", icon: "tree.circle.fill")
                    }
                    
                    HStack {
                        AccountStatCard(title: "削減したCO₂", value: "156kg", icon: "leaf.circle.fill")
                        AccountStatCard(title: "最高ストリーク", value: "12", icon: "flame.circle.fill")
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button("プロフィール編集") {
                        // Edit profile action
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    
                    Button("パスワードを変更") {
                        // Change password action
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
            .navigationTitle("アカウント")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完了") {
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
                Text("📊 データをエクスポート")
                    .font(.title)
                    .fontWeight(.semibold)
                    .padding(.top, 32)
                
                Text("習慣のトラッキングデータや環境への影響の統計をダウンロードできます。")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                VStack(spacing: 16) {
                    ExportOption(
                        title: "習慣の進捗",
                        description: "習慣の完了とストリークのデータ",
                        format: "CSV"
                    )
                    
                    ExportOption(
                        title: "環境への影響",
                        description: "CO₂、節水、ごみ削減のデータ",
                        format: "PDF"
                    )
                    
                    ExportOption(
                        title: "日記エントリ",
                        description: "あなたの振り返りと気分データ",
                        format: "JSON"
                    )
                    
                    ExportOption(
                        title: "全データ",
                        description: "すべてをまとめてダウンロード",
                        format: "ZIP"
                    )
                }
                .padding(.horizontal)
                
                Spacer()
                
                Button("すべてのデータをエクスポート") {
                    // Export functionality
                    dismiss()
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
            .navigationTitle("データをエクスポート")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("キャンセル") {
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

