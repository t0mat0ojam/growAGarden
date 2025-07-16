import SwiftUI

// MARK: - Plant Model

enum PlantState: String, Codable {
    case seed, sprout, wilt
}

struct Plant: Identifiable {
    let id = UUID()
    let habit: String
    var state: PlantState = .seed
    var growthLevel: Int = 0 // 🌱 -> 🌿 -> 🌳 -> 🌲
}

// MARK: - Main View: NextPageView (Your Forest)

struct NextPageView: View {
    @State private var plants: [Plant]
    @State private var selectedPlant: Plant?
    @State private var showCheckIn = false

    // Footer navigation state
    @State private var showJournaling = false
    @State private var showSettings = false

    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 4)

    init(habits: [String] = [
        "Sleep for 8 hours",
        "Read for 30 minutes",
        "Workout for 30 minutes"
    ]) {
        _plants = State(initialValue: habits.map { Plant(habit: $0) })
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color.green.opacity(0.13), Color.brown.opacity(0.09)],
                    startPoint: .top,
                    endPoint: .bottom
                ).ignoresSafeArea()

                VStack(spacing: 0) {
                    // Main forest grid content
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Your Forest")
                            .font(.system(size: 34, weight: .heavy, design: .rounded))
                            .foregroundColor(.green)
                            .padding(.leading, 18)
                            .padding(.top, 16)

                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 30) {
                                ForEach(plants) { plant in
                                    PlantView(plant: plant)
                                        .onTapGesture {
                                            selectedPlant = plant
                                            showCheckIn = true
                                        }
                                        .padding(.vertical, 6)
                                        .offset(
                                            x: CGFloat.random(in: -8...8),
                                            y: CGFloat.random(in: -8...8)
                                        )
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 30)
                        }
                    }

                    Spacer()

                    // Footer navigation bar
                    HStack {
                        Button(action: { showJournaling = true }) {
                            VStack {
                                Image(systemName: "book.closed")
                                    .font(.title2)
                                Text("Journaling")
                                    .font(.caption)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .sheet(isPresented: $showJournaling) {
                            JournalingView()
                        }

                        Button(action: { }) {
                            VStack {
                                Image(systemName: "leaf.circle.fill")
                                    .font(.title2)
                                Text("Home")
                                    .font(.caption)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        // Home doesn't navigate; you are on the home screen

                        Button(action: { showSettings = true }) {
                            VStack {
                                Image(systemName: "gearshape")
                                    .font(.title2)
                                Text("Settings")
                                    .font(.caption)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .sheet(isPresented: $showSettings) {
                            SettingsView()
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .shadow(color: .black.opacity(0.08), radius: 8, y: -2)
                    .padding(.bottom, 18)
                }
            }
            .sheet(isPresented: $showCheckIn) {
                if let idx = plants.firstIndex(where: { $0.id == selectedPlant?.id }) {
                    HabitCheckInView(plant: $plants[idx])
                }
            }
        }
    }
}

// MARK: - Plant View

struct PlantView: View {
    let plant: Plant

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(colorForState(plant.state))
                    .frame(width: 52, height: 52)
                    .shadow(color: Color.green.opacity(0.08), radius: 7, x: 0, y: 2)

                Text(emojiForGrowth(plant))
                    .font(.title)
            }

            Text(plant.habit)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 80)
        }
    }

    func colorForState(_ state: PlantState) -> Color {
        switch state {
        case .seed: return Color.brown.opacity(0.55)
        case .sprout: return Color.green.opacity(0.68)
        case .wilt: return Color.gray.opacity(0.4)
        }
    }

    func emojiForGrowth(_ plant: Plant) -> String {
        switch (plant.state, plant.growthLevel) {
        case (.seed, _): return "🌱"
        case (.sprout, 0): return "🌿"
        case (.sprout, 1): return "🌳"
        case (.sprout, _): return "🌲"
        case (.wilt, _): return "🥀"
        }
    }
}

// MARK: - Habit Check-In Modal

struct HabitCheckInView: View {
    @Binding var plant: Plant
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Did you complete this habit today?")
                .font(.title2)
                .fontWeight(.semibold)

            Text(plant.habit)
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.bottom, 10)

            HStack(spacing: 30) {
                // ✅ Mark as complete
                Button {
                    plant.state = .sprout
                    plant.growthLevel += 1
                    dismiss()
                } label: {
                    Text("Yes ✅")
                        .font(.headline)
                        .padding()
                        .frame(width: 120)
                        .background(Color.green.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(14)
                }

                // ❌ Mark as incomplete
                Button {
                    plant.state = .wilt
                    dismiss()
                } label: {
                    Text("No ❌")
                        .font(.headline)
                        .padding()
                        .frame(width: 120)
                        .background(Color.gray.opacity(0.5))
                        .foregroundColor(.white)
                        .cornerRadius(14)
                }
            }

            Spacer()
        }
        .padding()
    }
}

