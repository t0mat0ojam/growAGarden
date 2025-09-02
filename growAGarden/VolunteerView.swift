import SwiftUI

struct VolunteerView: View {
    @State private var selectedOpportunity: VolunteerOpportunity?
    @State private var showingSignUpSheet = false
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
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
                        // Header
                        VStack(spacing: 12) {
                            HStack {
                                Text("🤝")
                                    .font(.system(size: 32))
                                Text("Volunteer Opportunities")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                                Text("🌱")
                                    .font(.system(size: 32))
                            }
                            
                            Text("Make a difference in your community")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 16)
                        
                        // Search bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.secondary)
                            
                            TextField("Search opportunities...", text: $searchText)
                                .textFieldStyle(PlainTextFieldStyle())
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.8))
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                        .padding(.horizontal)
                        
                        // Featured opportunity
                        VStack(alignment: .leading, spacing: 16) {
                            Text("🌟 Featured This Week")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .padding(.horizontal)
                            
                            FeaturedOpportunityCard()
                                .padding(.horizontal)
                        }
                        
                        // Categories
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Browse by Category")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .padding(.horizontal)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                                CategoryCard(
                                    title: "Environment",
                                    icon: "leaf.fill",
                                    color: .green,
                                    count: 1
                                )
                                
                                CategoryCard(
                                    title: "Community",
                                    icon: "house.fill",
                                    color: .blue,
                                    count: 0
                                )
                                
                                CategoryCard(
                                    title: "Education",
                                    icon: "book.fill",
                                    color: .orange,
                                    count: 0
                                )
                                
                                CategoryCard(
                                    title: "Health",
                                    icon: "heart.fill",
                                    color: .red,
                                    count: 0
                                )
                            }
                            .padding(.horizontal)
                        }
                        
                        // Single Volunteer Opportunity
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Available Opportunity")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .padding(.horizontal)
                            
                            VolunteerOpportunityCard(opportunity: singleOpportunity) {
                                selectedOpportunity = singleOpportunity
                                showingSignUpSheet = true
                            }
                            .padding(.horizontal)
                        }
                        VStack(spacing: 16) {
                            Text("💡 Tip")
                                .font(.headline)
                                .fontWeight(.bold)
                            
                            Text("Volunteering not only helps your community but also contributes to your personal growth and well-being!")
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
    
    // Single volunteer opportunity
    private var singleOpportunity: VolunteerOpportunity {
        VolunteerOpportunity(
            title: "Tree Planting Event",
            organization: "Tokyo Green Initiative",
            date: "This Sunday, 8:00 AM - 12:00 PM",
            location: "Setagaya Park",
            description: "Join us for our special tree planting event at Setagaya Park! Help make Tokyo greener while meeting fellow environmental enthusiasts. All materials and refreshments provided.",
            category: .environment,
            duration: "4 hours",
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
        case .environment: return "Environment"
        case .community: return "Community"
        case .education: return "Education"
        case .health: return "Health"
        }
    }
}

// MARK: - Components
struct FeaturedOpportunityCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("🌳 Tree Planting Event")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("Tokyo Green Initiative")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.green)
                        Text("This Sunday, 8:00 AM")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                    }
                    
                    HStack {
                        Image(systemName: "location")
                            .foregroundColor(.green)
                        Text("Setagaya Park")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                    }
                }
                
                Spacer()
                
                VStack {
                    Text("🌲")
                        .font(.system(size: 40))
                    
                    Text("15 spots left")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.green)
                }
            }
            
            Text("Join us for our special tree planting event at Setagaya Park! Help make Tokyo greener while meeting fellow environmental enthusiasts.")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .lineLimit(nil)
            
            // Secret prize indicator
            HStack {
                Text("🎁")
                    .font(.title2)
                Text("Participants receive a secret prize!")
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
                // Handle sign up action
            }) {
                Text("Sign Up Now")
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
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("opportunities")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
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
                    
                    Text("spots left")
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
                Text("Learn More & Sign Up")
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
                        // Header
                        VStack(spacing: 12) {
                            Text("Sign Up to Volunteer")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Text(opportunity.title)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.blue)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top)
                        
                        // Opportunity details
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
                        
                        // Form
                        VStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Your Information")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                TextField("Full Name", text: $name)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                
                                TextField("Email Address", text: $email)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .textInputAutocapitalization(.never)
                                    .disableAutocorrection(true)
                                
                                TextField("Phone Number", text: $phone)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                        }
                        .padding(.horizontal)
                        
                        // Sign up button
                        Button(action: {
                            showingConfirmation = true
                        }) {
                            Text("Complete Sign Up")
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
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .alert("Thank You!", isPresented: $showingConfirmation) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("You've successfully signed up for \(opportunity.title)! You'll receive a confirmation email shortly.")
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
