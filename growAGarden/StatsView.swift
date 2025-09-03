import SwiftUI

// Uses ImpactStore / TimeFrame / ImpactTotals from ImpactStore.swift
struct StatsView: View {
    @ObservedObject private var store = ImpactStore.shared
    @State private var timeframe: TimeFrame = .week

    private var totals: ImpactTotals { store.totals(in: timeframe) }
    private var rollups: [ImpactStore.HabitRollup] { store.habitRollups(in: timeframe) }

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(.systemBlue).opacity(0.10),
                        Color(.systemGreen).opacity(0.06),
                        Color(.systemMint).opacity(0.10)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        header
                        timeframePicker
                        summaryGrid
                        moneyCard
                        treesEquivalent
                        habitSection
                        motivation
                    }
                    .padding(.bottom, 28)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Sections

    private var header: some View {
        VStack(spacing: 8) {
            Text("🌍 Your Environmental Impact")
                .font(.system(size: 28, weight: .bold, design: .rounded))
            Text("Every habit counts towards a greener planet")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
        }
        .padding(.top, 16)
    }

    private var timeframePicker: some View {
        Picker("Time Frame", selection: $timeframe) {
            Text("This Week").tag(TimeFrame.week)
            Text("This Month").tag(TimeFrame.month)
            Text("This Year").tag(TimeFrame.year)
            Text("All Time").tag(TimeFrame.allTime)
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
    }

    private var summaryGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
            MetricCard(
                title: "CO₂ Reduced",
                value: String(format: "%.1f kg", totals.co2SavedKg),
                icon: "leaf.fill",
                tint: Color.green,
                subtitle: "Carbon footprint"
            )
            MetricCard(
                title: "Energy Saved",
                value: String(format: "%.1f kWh", totals.energySavedKWh),
                icon: "bolt.fill",
                tint: Color.yellow,
                subtitle: "Electricity / fuel"
            )
            MetricCard(
                title: "Water Saved",
                value: String(format: "%.0f L", totals.waterSavedL),
                icon: "drop.fill",
                tint: Color.blue,
                subtitle: "Manufacturing water"
            )
            MetricCard(
                title: "Waste Diverted",
                value: String(format: "%.1f kg", totals.wasteDivertedKg),
                icon: "arrow.3.trianglepath",
                tint: Color.orange,
                subtitle: "From landfills"
            )
            MetricCard(
                title: "Plastic Avoided",
                value: String(format: "%.0f g", totals.plasticSavedKg * 1000),
                icon: "cube.transparent",
                tint: Color.teal,
                subtitle: "Single-use items"
            )
        }
        .padding(.horizontal)
    }

    private var moneyCard: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "yensign.circle.fill")
                    .foregroundColor(Color.green)
                    .font(.title2)
                Text("Money Saved")
                    .font(.headline)
                Spacer()
            }
            HStack {
                Text("¥\(Int(totals.moneySavedJPY))")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                Spacer()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.green.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.green.opacity(0.2), lineWidth: 1)
                )
        )
        .padding(.horizontal)
    }

    private var treesEquivalent: some View {
        let trees = totals.co2SavedKg / 21.0 // rough: ~21 kg CO2 per tree per year
        return VStack(spacing: 12) {
            HStack {
                Image(systemName: "tree.fill").foregroundColor(.green).font(.title2)
                Text("Trees Planted Equivalent")
                    .font(.headline)
                Spacer()
            }
            HStack {
                ForEach(0..<min(Int(trees), 10), id: \.self) { _ in
                    Text("🌳").font(.title)
                }
                if trees > 10 {
                    Text("+\(Int(trees - 10))")
                        .font(.headline)
                        .foregroundColor(.green)
                }
                Spacer()
            }
            Text(String(format: "%.1f trees worth of CO₂ absorbed", trees))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.green.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.green.opacity(0.2), lineWidth: 1)
                )
        )
        .padding(.horizontal)
    }

    private var habitSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Habit Performance")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.horizontal)

            ForEach(rollups) { r in
                HabitCard(
                    habitName: r.habitName,
                    streakDays: r.currentStreakDays,
                    completionRate: r.completionRate,
                    totals: r.totals
                )
                .padding(.horizontal)
            }
        }
    }

    private var motivation: some View {
        VStack(spacing: 12) {
            Text("🎯 Keep It Up!")
                .font(.title2)
                .fontWeight(.bold)
            Text(motivationalMessage(totalCO2: totals.co2SavedKg))
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.blue.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                )
        )
        .padding(.horizontal)
    }

    private func motivationalMessage(totalCO2: Double) -> String {
        switch totalCO2 {
        case let x where x > 50:
            return "Incredible! Your impact rivals planting dozens of trees this year."
        case let x where x > 20:
            return "Great work! Your consistent choices are adding up fast."
        case let x where x > 5:
            return "Nice start! Keep logging your wins—every day counts."
        default:
            return "Welcome to your sustainability journey. Small steps → big change."
        }
    }
}

// MARK: - Local reusable views

private struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    let tint: Color
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .foregroundColor(tint)
                    .font(.title2)
                Text(title)
                    .font(.headline)
            }
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
            Text(subtitle)
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(tint.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(tint.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

private struct HabitCard: View {
    let habitName: String
    let streakDays: Int
    let completionRate: Double
    let totals: ImpactTotals

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(habitName)
                    .font(.headline)
                Spacer()
                if streakDays > 0 {
                    Label("\(streakDays)d", systemImage: "flame.fill")
                        .labelStyle(.titleAndIcon)
                        .font(.subheadline)
                        .foregroundColor(.orange)
                }
            }

            ProgressView(value: min(1.0, max(0.0, completionRate)))
                .tint(.green)
                .animation(.easeInOut(duration: 0.3), value: completionRate)

            HStack(spacing: 12) {
                ImpactMetric(icon: "leaf.fill",
                             text: String(format: "%.1f kg CO₂", totals.co2SavedKg))
                ImpactMetric(icon: "bolt.fill",
                             text: String(format: "%.1f kWh", totals.energySavedKWh))
                ImpactMetric(icon: "yensign.circle.fill",
                             text: "¥\(Int(totals.moneySavedJPY))")
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.92))
                .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
        )
    }
}

private struct ImpactMetric: View {
    let icon: String
    let text: String
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundColor(.secondary)
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

