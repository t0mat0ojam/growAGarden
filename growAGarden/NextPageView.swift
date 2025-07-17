import SwiftUI

// MARK: - Plant Model

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

// Enum to define the tabs for clearer selection management
enum TabSelection: String, CaseIterable, Identifiable {
    case journaling = "Journaling"
    case home = "Home"
    case stats = "Stats"
    case settings = "Settings"

    var id: String { self.rawValue }
    
    // SF Symbol for each tab
    var systemImage: String {
        switch self {
        case .journaling: return "book.closed"
        case .home: return "leaf.circle.fill"
        case .stats: return "chart.bar.fill"
        case .settings: return "gearshape"
        }
    }
}


// MARK: - Main View: NextPageView (Your Forest)

struct NextPageView: View {
    @State private var plants: [Plant]
    @State private var selectedPlant: Plant?
    @State private var showCheckIn = false
    
    // State to control the currently selected tab for TabView
    @State private var selectedTab: TabSelection = .home
    
    let gridSize = 4 // 4x4 grid
    
    // Initializer now accepts a 'habits' array from ContentView
    init(habits: [String]) {
        _plants = State(initialValue: habits.enumerated().map { index, habit in
            let row = index / 4
            let col = index % 4
            return Plant(habit: habit, position: GridPosition(row: row, col: col))
        })
    }
    
    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                // Journaling Tab Content
                JournalingView()
                    .tag(TabSelection.journaling)
                    .tabItem {
                        VStack {
                            Image(systemName: TabSelection.journaling.systemImage)
                                .font(.title2)
                            Text(TabSelection.journaling.rawValue)
                                .font(.caption)
                        }
                        .scaleEffect(selectedTab == .journaling ? 1.2 : 1.0)
                        .fontWeight(selectedTab == .journaling ? .bold : .regular)
                        .animation(.spring(), value: selectedTab)
                    }
                
                // Home Tab Content (Original NextPageView content, now in a subview)
                ForestGridView(plants: $plants, selectedPlant: $selectedPlant, showCheckIn: $showCheckIn)
                    .tag(TabSelection.home)
                    .tabItem {
                        VStack {
                            Image(systemName: TabSelection.home.systemImage)
                                .font(.title2)
                            Text(TabSelection.home.rawValue)
                                .font(.caption)
                        }
                        .scaleEffect(selectedTab == .home ? 1.2 : 1.0)
                        .fontWeight(selectedTab == .home ? .bold : .regular)
                        .animation(.spring(), value: selectedTab)
                    }
                
                // Stats Tab Content
                StatsView()
                    .tag(TabSelection.stats)
                    .tabItem {
                        VStack {
                            Image(systemName: TabSelection.stats.systemImage)
                                .font(.title2)
                            Text(TabSelection.stats.rawValue)
                                .font(.caption)
                        }
                        .scaleEffect(selectedTab == .stats ? 1.2 : 1.0)
                        .fontWeight(selectedTab == .stats ? .bold : .regular)
                        .animation(.spring(), value: selectedTab)
                    }
                
                // Settings Tab Content
                SettingsView()
                    .tag(TabSelection.settings)
                    .tabItem {
                        VStack {
                            Image(systemName: TabSelection.settings.systemImage)
                                .font(.title2)
                            Text(TabSelection.settings.rawValue)
                                .font(.caption)
                        }
                        .scaleEffect(selectedTab == .settings ? 1.2 : 1.0)
                        .fontWeight(selectedTab == .settings ? .bold : .regular)
                        .animation(.spring(), value: selectedTab)
                    }
            }
            .sheet(isPresented: $showCheckIn) {
                if let idx = plants.firstIndex(where: { $0.id == selectedPlant?.id }) {
                    HabitCheckInView(plant: $plants[idx])
                }
            }
            // Hide the navigation bar's back button
            .navigationBarBackButtonHidden(true)
        }
    }
    
    // New struct to encapsulate the original forest grid content with layout adjustments
    struct ForestGridView: View {
        @Binding var plants: [Plant]
        @Binding var selectedPlant: Plant?
        @Binding var showCheckIn: Bool
        
        let gridSize = 4 // 4x4 grid
        let columns: [GridItem] = Array(repeating: .init(.fixed(100)), count: 4)
        
        var body: some View {
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
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(0..<(gridSize * gridSize), id: \.self) { index in
                                let row = index / gridSize
                                let col = index % gridSize
                                let pos = GridPosition(row: row, col: col)
                                
                                if let plant = plants.first(where: { $0.position == pos }) {
                                    PlantView(plant: plant)
                                        .onTapGesture {
                                            selectedPlant = plant
                                            showCheckIn = true
                                        }
                                } else {
                                    GrassTileView()
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, 40)
                        .padding(.horizontal, 16)
                    }
                    Spacer()
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
                        .offset(y: arrowOffset)
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
                arrowOffset = -10
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
