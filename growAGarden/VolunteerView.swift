import SwiftUI

struct VolunteerView: View {
    @State private var selectedOpportunity: VolunteerOpportunity?
    @State private var showingSignUpSheet = false
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                // 背景グラデーション
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(.systemBlue).opacity(0.1),
                        Color(.systemPurple).opacity(0.05),
                        Color(.systemIndigo).opacity(0.1)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // ヘッダー
                        VStack(spacing: 12) {
                            HStack {
                                Text("🤝")
                                    .font(.system(size: 32))
                                Text("ボランティア募集")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                                Text("🌱")
                                    .font(.system(size: 32))
                            }
                            
                            Text("地域のために、あなたの力を活かしましょう")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 16)
                        
                        // 検索バー
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.secondary)
                            
                            TextField("ボランティアを検索...", text: $searchText)
                                .textFieldStyle(PlainTextFieldStyle())
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.8))
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                        .padding(.horizontal)
                        
                        // 注目のボランティア
                        VStack(alignment: .leading, spacing: 16) {
                            Text("🌟 今週の注目")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .padding(.horizontal)
                            
                            FeaturedOpportunityCard()
                                .padding(.horizontal)
                        }
                        
                        // カテゴリ別
                        VStack(alignment: .leading, spacing: 16) {
                            Text("カテゴリから探す")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .padding(.horizontal)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                                CategoryCard(
                                    title: "環境",
                                    icon: "leaf.fill",
                                    color: .green,
                                    count: 1
                                )
                                
                                CategoryCard(
                                    title: "地域",
                                    icon: "house.fill",
                                    color: .blue,
                                    count: 0
                                )
                                
                                CategoryCard(
                                    title: "教育",
                                    icon: "book.fill",
                                    color: .orange,
                                    count: 0
                                )
                                
                                CategoryCard(
                                    title: "健康",
                                    icon: "heart.fill",
                                    color: .red,
                                    count: 0
                                )
                            }
                            .padding(.horizontal)
                        }
                        
                        // 単発ボランティア
                        VStack(alignment: .leading, spacing: 16) {
                            Text("募集中の活動")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .padding(.horizontal)
                            
                            VolunteerOpportunityCard(opportunity: singleOpportunity) {
                                selectedOpportunity = singleOpportunity
                                showingSignUpSheet = true
                            }
                            .padding(.horizontal)
                        }
                        
                        // ヒント
                        VStack(spacing: 16) {
                            Text("💡 ワンポイント")
                                .font(.headline)
                                .fontWeight(.bold)
                            
                            Text("ボランティアは地域に貢献できるだけでなく、あなた自身の成長や心の健康にもつながります！")
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.purple.opacity(0.05))
                                .stroke(Color.purple.opacity(0.2), lineWidth: 1)
                        )
                        .padding(.horizontal)
                        .padding(.bottom, 32)
                    }
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .sheet(isPresented: $showingSignUpSheet) {
                if let opportunity = selectedOpportunity {
                    VolunteerSignUpSheet(opportunity: opportunity)
                }
            }
        }
    }
    
    // 単発の例
    private var singleOpportunity: VolunteerOpportunity {
        VolunteerOpportunity(
            title: "植樹イベント",
            organization: "東京グリーンイニシアチブ",
            date: "今週日曜 8:00〜12:00",
            location: "世田谷公園",
            description: "世田谷公園での特別な植樹イベントに参加しませんか？東京をもっと緑豊かにしながら、環境に関心のある仲間と出会えます。道具や飲み物はすべて用意されています。",
            category: .environment,
            duration: "4時間",
            spotsAvailable: 15
        )
    }
}

// MARK: - Models
struct VolunteerOpportunity: Identifiable {
    let id = UUID()
    let title: String
    let organization: String
    let date: String
    let location: String
    let description: String
    let category: VolunteerCategory
    let duration: String
    let spotsAvailable: Int
}

enum VolunteerCategory {
    case environment, community, education, health
    
    var displayName: String {
        switch self {
        case .environment: return "環境"
        case .community: return "地域"
        case .education: return "教育"
        case .health: return "健康"
        }
    }
}

// MARK: - Components
struct FeaturedOpportunityCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("🌳 植樹イベント")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("東京グリーンイニシアチブ")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.green)
                        Text("今週日曜 8:00〜")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                    }
                    
                    HStack {
                        Image(systemName: "location")
                            .foregroundColor(.green)
                        Text("世田谷公園")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                    }
                }
                
                Spacer()
                
                VStack {
                    Text("🌲")
                        .font(.system(size: 40))
                    
                    Text("残り15枠")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.green)
                }
            }
            
            Text("世田谷公園での特別な植樹イベントに参加して、東京をもっと緑豊かにしましょう！環境活動に関心のある仲間と出会えます。")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            
            HStack {
                Text("🎁")
                    .font(.title2)
                Text("参加者には秘密のプレゼントあり！")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.purple)
                Text("❓")
                    .font(.title2)
                Spacer()
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.purple.opacity(0.1))
            )
            
            Button(action: {
                // 申し込み処理
            }) {
                Text("今すぐ申し込む")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.green, Color.mint]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.9))
                .shadow(color: Color.green.opacity(0.15), radius: 8, x: 0, y: 4)
        )
    }
}

struct CategoryCard: View {
    let title: String
    let icon: String
    let color: Color
    let count: Int
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title2)
                Spacer()
                Text("\(count)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text("件の募集")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.85))
                .shadow(color: color.opacity(0.15), radius: 6, x: 0, y: 3)
        )
    }
}

struct VolunteerOpportunityCard: View {
    let opportunity: VolunteerOpportunity
    let onSignUp: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(opportunity.title)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text(opportunity.organization)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(opportunity.spotsAvailable)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.blue)
                    
                    Text("残り枠")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.blue)
                        .frame(width: 16)
                    Text(opportunity.date)
                        .font(.system(size: 14))
                        .foregroundColor(.primary)
                }
                
                HStack {
                    Image(systemName: "location")
                        .foregroundColor(.blue)
                        .frame(width: 16)
                    Text(opportunity.location)
                        .font(.system(size: 14))
                        .foregroundColor(.primary)
                }
                
                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(.blue)
                        .frame(width: 16)
                    Text(opportunity.duration)
                        .font(.system(size: 14))
                        .foregroundColor(.primary)
                }
            }
            
            Text(opportunity.description)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .lineLimit(3)
            
            Button(action: onSignUp) {
                Text("詳細・申し込み")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.blue.opacity(0.1))
                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                    )
                    .foregroundColor(.blue)
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.85))
                .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 3)
        )
    }
}

// MARK: - Sign Up Sheet
struct VolunteerSignUpSheet: View {
    let opportunity: VolunteerOpportunity
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var showingConfirmation = false
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(.systemBlue).opacity(0.05),
                        Color(.systemPurple).opacity(0.05)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // ヘッダー
                        VStack(spacing: 12) {
                            Text("ボランティアに申し込む")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Text(opportunity.title)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.blue)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top)
                        
                        // 詳細
                        VStack(alignment: .leading, spacing: 12) {
                            DetailRow(icon: "building.2", text: opportunity.organization)
                            DetailRow(icon: "calendar", text: opportunity.date)
                            DetailRow(icon: "location", text: opportunity.location)
                            DetailRow(icon: "clock", text: opportunity.duration)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.8))
                        )
                        .padding(.horizontal)
                        
                        // フォーム
                        VStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("あなたの情報")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                TextField("氏名", text: $name)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                
                                TextField("メールアドレス", text: $email)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .textInputAutocapitalization(.never)
                                    .disableAutocorrection(true)
                                
                                TextField("電話番号", text: $phone)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                        }
                        .padding(.horizontal)
                        
                        // ボタン
                        Button(action: {
                            showingConfirmation = true
                        }) {
                            Text("申し込みを完了する")
                                .font(.system(size: 18, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.blue, Color.purple]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        .disabled(name.isEmpty || email.isEmpty)
                        
                        Spacer(minLength: 100)
                    }
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }
            .alert("ありがとうございます！", isPresented: $showingConfirmation) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("\(opportunity.title) に申し込みが完了しました。確認メールをお送りします。")
            }
        }
    }
}

struct DetailRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            Text(text)
                .font(.system(size: 16))
                .foregroundColor(.primary)
            Spacer()
        }
    }
}

// MARK: - Preview
struct VolunteerView_Previews: PreviewProvider {
    static var previews: some View {
        VolunteerView()
    }
}

