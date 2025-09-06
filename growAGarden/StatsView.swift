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
            Text("🌍 あなたの環境への影響")
                .font(.system(size: 28, weight: .bold, design: .rounded))
            Text("すべての習慣がよりグリーンな地球に貢献します")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
        }
        .padding(.top, 16)
    }

    private var timeframePicker: some View {
        Picker("期間", selection: $timeframe) {
            Text("今週").tag(TimeFrame.week)
            Text("今月").tag(TimeFrame.month)
            Text("今年").tag(TimeFrame.year)
            Text("全期間").tag(TimeFrame.allTime)
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
    }

    private var summaryGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
            MetricCard(
                title: "削減したCO₂",
                value: String(format: "%.1f kg", totals.co2SavedKg),
                icon: "leaf.fill",
                tint: Color.green,
                subtitle: "カーボンフットプリント"
            )
            MetricCard(
                title: "節約したエネルギー",
                value: String(format: "%.1f kWh", totals.energySavedKWh),
                icon: "bolt.fill",
                tint: Color.yellow,
                subtitle: "電力 / 燃料"
            )
            MetricCard(
                title: "節水量",
                value: String(format: "%.0f L", totals.waterSavedL),
                icon: "drop.fill",
                tint: Color.blue,
                subtitle: "製造に使われる水"
            )
            MetricCard(
                title: "廃棄物削減量",
                value: String(format: "%.1f kg", totals.wasteDivertedKg),
                icon: "arrow.3.trianglepath",
                tint: Color.orange,
                subtitle: "埋立地から回避"
            )
            MetricCard(
                title: "プラスチック削減量",
                value: String(format: "%.0f g", totals.plasticSavedKg * 1000),
                icon: "cube.transparent",
                tint: Color.teal,
                subtitle: "使い捨てアイテム"
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
                Text("節約金額")
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
                Text("植樹換算")
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
            Text(String(format: "%.1f 本分のCO₂吸収量", trees))
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
            Text("習慣の実績")
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
            Text("🎯 頑張ろう！")
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
            return "素晴らしい！今年植樹した木に匹敵する影響です。"
        case let x where x > 20:
            return "素敵な取り組みです！日々の積み重ねが大きな成果に。"
        case let x where x > 5:
            return "良いスタートです！毎日の達成を記録し続けましょう。"
        default:
            return "持続可能な旅へようこそ。小さな一歩が大きな変化につながります。"
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

