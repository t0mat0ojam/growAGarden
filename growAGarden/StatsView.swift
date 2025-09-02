import SwiftUI

// MARK: - Environmental Impact Model
struct EnvironmentalImpact {
    var co2Saved: Double = 0      // in kg
    var waterSaved: Double = 0    // in gallons
    var wasteDiverted: Double = 0 // in pounds
    var energySaved: Double = 0   // in kWh
    var treesEquivalent: Double = 0 // trees planted equivalent
}

struct HabitImpactData {
    static let dailyImpacts: [String: EnvironmentalImpact] = [
        "Use reusable water bottle": EnvironmentalImpact(co2Saved: 0.08, waterSaved: 0.5, wasteDiverted: 0.03, energySaved: 0.1, treesEquivalent: 0.001),
        "Take public transport": EnvironmentalImpact(co2Saved: 4.6, waterSaved: 2.0, wasteDiverted: 0.1, energySaved: 5.2, treesEquivalent: 0.21),
        "Unplug electronics when not in use": EnvironmentalImpact(co2Saved: 1.2, waterSaved: 0.8, wasteDiverted: 0.05, energySaved: 2.4, treesEquivalent: 0.05),
        "Sleep for 8 hours": EnvironmentalImpact(co2Saved: 0.5, waterSaved: 0.3, wasteDiverted: 0.02, energySaved: 0.8, treesEquivalent: 0.02),
        "Read for 30 minutes": EnvironmentalImpact(co2Saved: 0.1, waterSaved: 0.1, wasteDiverted: 0.01, energySaved: 0.2, treesEquivalent: 0.004),
        "Workout for 30 minutes": EnvironmentalImpact(co2Saved: 0.3, waterSaved: 0.2, wasteDiverted: 0.01, energySaved: 0.4, treesEquivalent: 0.01)
    ]
}

// MARK: - Stats View
struct StatsView: View {
    @State private var selectedTimeframe: TimeFrame = .week
    @State private var totalImpact = EnvironmentalImpact()
    @State private var habitStats: [HabitStat] = []
    
    enum TimeFrame: String, CaseIterable {
        case week = "This Week"
        case month = "This Month"
        case year = "This Year"
        case allTime = "All Time"
        
        var multiplier: Double {
            switch self {
            case .week: return 7
            case .month: return 30
            case .year: return 365
            case .allTime: return 500 // Assuming max usage
            }
        }
    }
    
    struct HabitStat: Identifiable {
        let id = UUID()
        let habitName: String
        let completionRate: Double
        let streak: Int
        let impact: EnvironmentalImpact
    }

    var body: some View {
        NavigationView {
            ZStack {
                // Earth-themed gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(.systemBlue).opacity(0.1),
                        Color(.systemGreen).opacity(0.05),
                        Color(.systemMint).opacity(0.1)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            Text("🌍 Your Environmental Impact")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                            
                            Text("Every habit counts towards a greener planet")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 16)
                        
                        // Time Frame Picker
                        Picker("Time Frame", selection: $selectedTimeframe) {
                            ForEach(TimeFrame.allCases, id: \.self) { timeframe in
                                Text(timeframe.rawValue).tag(timeframe)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)
                        
                        // Impact Summary Cards
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                            ImpactCard(
                                title: "CO₂ Reduced",
                                value: String(format: "%.1f kg", totalImpact.co2Saved),
                                icon: "leaf.fill",
                                color: .green,
                                subtitle: "Carbon footprint"
                            )
                            
                            ImpactCard(
                                title: "Water Saved",
                                value: String(format: "%.0f gal", totalImpact.waterSaved),
                                icon: "drop.fill",
                                color: .blue,
                                subtitle: "Fresh water"
                            )
                            
                            ImpactCard(
                                title: "Waste Diverted",
                                value: String(format: "%.1f lbs", totalImpact.wasteDiverted),
                                icon: "arrow.3.trianglepath",
                                color: .orange,
                                subtitle: "From landfills"
                            )
                            
                            ImpactCard(
                                title: "Energy Saved",
                                value: String(format: "%.1f kWh", totalImpact.energySaved),
                                icon: "bolt.fill",
                                color: .yellow,
                                subtitle: "Clean energy"
                            )
                        }
                        .padding(.horizontal)
                        
                        // Trees Equivalent
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "tree.fill")
                                    .foregroundColor(.green)
                                    .font(.title2)
                                Text("Trees Planted Equivalent")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            
                            HStack {
                                ForEach(0..<min(Int(totalImpact.treesEquivalent), 10), id: \.self) { _ in
                                    Text("🌳")
                                        .font(.title)
                                }
                                if totalImpact.treesEquivalent > 10 {
                                    Text("+\(Int(totalImpact.treesEquivalent - 10))")
                                        .font(.headline)
                                        .foregroundColor(.green)
                                }
                                Spacer()
                            }
                            
                            Text(String(format: "%.1f trees worth of CO₂ absorbed", totalImpact.treesEquivalent))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.green.opacity(0.05))
                                .stroke(Color.green.opacity(0.2), lineWidth: 1)
                        )
                        .padding(.horizontal)
                        
                        // Habit Performance
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Habit Performance")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .padding(.horizontal)
                            
                            ForEach(habitStats) { stat in
                                HabitStatCard(stat: stat)
                            }
                        }
                        
                        // Motivation Section
                        VStack(spacing: 12) {
                            Text("🎯 Keep It Up!")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(getMotivationalMessage())
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.blue.opacity(0.05))
                                .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                        )
                        .padding(.horizontal)
                        .padding(.bottom, 32)
                    }
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .onAppear {
                calculateTotalImpact()
                generateHabitStats()
            }
            .onChange(of: selectedTimeframe) { _ in
                calculateTotalImpact()
                generateHabitStats()
            }
        }
    }
    
    // MARK: - Helper Functions
    private func calculateTotalImpact() {
        let multiplier = selectedTimeframe.multiplier
        
        // Mock calculation - replace with real data from your habit tracking
        let mockCompletionRate = 0.75 // 75% completion rate
        let mockHabits = ["Use reusable water bottle", "Take public transport", "Unplug electronics when not in use"]
        
        var impact = EnvironmentalImpact()
        
        for habit in mockHabits {
            if let dailyImpact = HabitImpactData.dailyImpacts[habit] {
                impact.co2Saved += dailyImpact.co2Saved * multiplier * mockCompletionRate
                impact.waterSaved += dailyImpact.waterSaved * multiplier * mockCompletionRate
                impact.wasteDiverted += dailyImpact.wasteDiverted * multiplier * mockCompletionRate
                impact.energySaved += dailyImpact.energySaved * multiplier * mockCompletionRate
                impact.treesEquivalent += dailyImpact.treesEquivalent * multiplier * mockCompletionRate
            }
        }
        
        totalImpact = impact
    }
    
    private func generateHabitStats() {
        // Mock data - replace with real habit tracking data
        habitStats = [
            HabitStat(
                habitName: "Use reusable water bottle",
                completionRate: 0.85,
                streak: 12,
                impact: EnvironmentalImpact(co2Saved: 0.96, waterSaved: 6.0, wasteDiverted: 0.36, energySaved: 1.2, treesEquivalent: 0.012)
            ),
            HabitStat(
                habitName: "Take public transport",
                completionRate: 0.71,
                streak: 5,
                impact: EnvironmentalImpact(co2Saved: 23.0, waterSaved: 10.0, wasteDiverted: 0.5, energySaved: 26.0, treesEquivalent: 1.05)
            ),
            HabitStat(
                habitName: "Unplug electronics",
                completionRate: 0.92,
                streak: 8,
                impact: EnvironmentalImpact(co2Saved: 8.28, waterSaved: 5.52, wasteDiverted: 0.345, energySaved: 16.56, treesEquivalent: 0.345)
            )
        ]
    }
    
    private func getMotivationalMessage() -> String {
        let totalCO2 = totalImpact.co2Saved
        
        if totalCO2 > 50 {
            return "Incredible! You're making a huge difference for our planet. Your habits have the same impact as planting \(String(format: "%.0f", totalImpact.treesEquivalent)) trees!"
        } else if totalCO2 > 20 {
            return "Great work! You're well on your way to making a meaningful environmental impact. Keep growing your green habits!"
        } else if totalCO2 > 5 {
            return "Nice start! Every small action adds up. You're already making a positive difference for the environment."
        } else {
            return "Welcome to your sustainability journey! Even small habits can create big changes over time."
        }
    }
}

// MARK: - Impact Card Component
struct ImpactCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title2)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.85))
                .shadow(color: color.opacity(0.15), radius: 8, x: 0, y: 4)
        )
    }
}

// MARK: - Habit Stat Card Component
struct HabitStatCard: View {
    let stat: StatsView.HabitStat
    
    var body: some View {
        VStack(spacing: 12) {
            // Header with habit name and completion rate
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(stat.habitName)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    HStack {
                        Text("\(Int(stat.completionRate * 100))% complete")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .foregroundColor(.orange)
                                .font(.caption)
                            Text("\(stat.streak) day streak")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.orange)
                        }
                    }
                }
                
                Spacer()
                
                // Completion rate circle
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 4)
                        .frame(width: 50, height: 50)
                    
                    Circle()
                        .trim(from: 0, to: stat.completionRate)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [.green, .mint]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 4, lineCap: .round)
                        )
                        .frame(width: 50, height: 50)
                        .rotationEffect(.degrees(-90))
                    
                    Text("\(Int(stat.completionRate * 100))%")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.primary)
                }
            }
            
            // Impact breakdown
            VStack(spacing: 8) {
                HStack {
                    Text("Environmental Impact:")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                    Spacer()
                }
                
                HStack(spacing: 16) {
                    ImpactMetric(
                        icon: "leaf.fill",
                        value: String(format: "%.1f kg", stat.impact.co2Saved),
                        label: "CO₂",
                        color: .green
                    )
                    
                    ImpactMetric(
                        icon: "drop.fill",
                        value: String(format: "%.0f gal", stat.impact.waterSaved),
                        label: "Water",
                        color: .blue
                    )
                    
                    ImpactMetric(
                        icon: "bolt.fill",
                        value: String(format: "%.1f kWh", stat.impact.energySaved),
                        label: "Energy",
                        color: .yellow
                    )
                    
                    Spacer()
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.85))
                .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 3)
        )
        .padding(.horizontal)
    }
}

// MARK: - Impact Metric Component
struct ImpactMetric: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.caption)
            
            Text(value)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Achievement Badge Component
struct AchievementBadge: View {
    let title: String
    let description: String
    let icon: String
    let isUnlocked: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? Color.yellow.opacity(0.2) : Color.gray.opacity(0.1))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .foregroundColor(isUnlocked ? .yellow : .gray)
                    .font(.title2)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isUnlocked ? .primary : .secondary)
                
                Text(description)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if isUnlocked {
                Text("✅")
                    .font(.title2)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isUnlocked ? Color.yellow.opacity(0.05) : Color.gray.opacity(0.05))
                .stroke(isUnlocked ? Color.yellow.opacity(0.3) : Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Preview
struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        StatsView()
    }
}
