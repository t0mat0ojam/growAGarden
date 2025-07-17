import SwiftUI

// MARK: - Plant Model1

enum PlantState: String, Codable {
    case seed, sprout, wilt
}

struct Plant: Identifiable, Equatable {
    let id = UUID()
    let habit: String
    var state: PlantState = .seed
    var growthLevel: Int = 0
    var position: GridPosition
}

struct GridPosition: Hashable {
    let row: Int
    let col: Int
}


// MARK: - Main View: NextPageView (Your Forest)

struct NextPageView: View {
    @State private var plants: [Plant]
    @State private var selectedPlant: Plant?
    @State private var showCheckIn = false
    
    // Footer navigation state
    @State private var showJournaling = false
    @State private var showSettings = false
    
    let gridSize = 4 // 4x4 grid
    
    init(habits: [String] = [
        "Sleep for 8 hours",
        "Read for 30 minutes",
        "Workout for 30 minutes"
    ]) {
        _plants = State(initialValue: habits.enumerated().map { index, habit in
            let row = index / 4
            let col = index % 4
            return Plant(habit: habit, position: GridPosition(row: row, col: col))
        })
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Image("grass_tile")
                    .resizable(resizingMode: .tile)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Text("Your Forest")
                        .font(.system(size: 34, weight: .heavy, design: .rounded))
                        .foregroundColor(.black)
                        .padding(.top, 16)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: .init(.fixed(100)), count: gridSize), spacing: 20) {
                            ForEach(0..<(gridSize * gridSize), id: \.self) { index in
                                let row = index / gridSize
                                let col = index % gridSize
                                let pos = GridPosition(row: row, col: col)
                                
                                if let plant = plants.first(where: { $0.position == pos }) {
                                    PlantView(plant: plant)
                                        .onTapGesture {
                                            selectedPlant = plant // ← Set selected plant
                                        }
                                } else {
                                    GrassTileView()
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, 40)
                    }
                    
                    Spacer()
                    
                    // Footer nav
                    HStack {
                        Button(action: { showJournaling = true }) {
                            VStack {
                                Image(systemName: "book.closed")
                                    .font(.title2)
                                Text("Journaling").font(.caption)
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
                                Text("Home").font(.caption)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        
                        Button(action: { showSettings = true }) {
                            VStack {
                                Image(systemName: "gearshape")
                                    .font(.title2)
                                Text("Settings").font(.caption)
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
                // Show check-in sheet only after selectedPlant is set
                .onChange(of: selectedPlant) { newValue in
                    if newValue != nil {
                        showCheckIn = true
                    }
                }
            }
            .sheet(isPresented: $showCheckIn) {
                if let idx = plants.firstIndex(where: { $0.id == selectedPlant?.id }) {
                    HabitCheckInView(plant: $plants[idx])
                }
            }
        }
    }
    
    
    // MARK: - Plant View
    struct PlantView: View {
        let plant: Plant

        // Controls arrow Y offset (animated)
        @State private var arrowOffset: CGFloat = -12

        var body: some View {
            ZStack {
                Image("grass_tile")
                    .resizable(resizingMode: .tile)
                    .aspectRatio(1, contentMode: .fill)
                    .frame(width: 100, height: 100)

                VStack(spacing: 0) {
                    Image(systemName: "arrow.down")
                        .font(.title3)
                        .foregroundColor(.orange)
                        .offset(y: arrowOffset) // Use smoothly animated numeric value only!
                    Spacer().frame(height: 4)
                    Text(emojiForGrowth(plant))
                        .font(.system(size: 40))
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 1, y: 1)
                }
                .frame(width: 100, height: 100)
            }
            .frame(width: 100, height: 100)
            .onAppear {
                animateArrow()
            }
        }

        // Animate up/down loop
        func animateArrow() {
            withAnimation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                arrowOffset = -10 // Change this value for more or less bounce (e.g., -12 to -10 = 2pt bounce)
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


    struct GrassTileView: View {
        var body: some View {
            Image("grass_tile")
                .resizable(resizingMode: .tile)
                .aspectRatio(1, contentMode: .fill)
                .frame(width: 100, height: 100)
                .clipped()
        }
    }
    
    // MARK: - Habit Check-In Modal
    struct HabitCheckInView: View {
        @Binding var plant: Plant
        @Environment(\.dismiss) var dismiss
        
        var body: some View {
            VStack(spacing: 24) {
                Spacer()
                
                // 🌱 Show the habit name (e.g., "Meditate")
                Text(plant.habit)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                
                Text("Did you complete this habit today?")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
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
}
