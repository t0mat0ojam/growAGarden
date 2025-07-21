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
    var lastCheckInDate: Date? = nil
}

struct GridPosition: Hashable {
    let row: Int
    let col: Int
}

enum TabSelection: String, CaseIterable, Identifiable {
    case journaling = "Journaling"
    case home = "Home"
    case stats = "Stats"
    case settings = "Settings"

    var id: String { self.rawValue }

    var systemImage: String {
        switch self {
        case .journaling: return "book.closed"
        case .home: return "leaf.circle.fill"
        case .stats: return "chart.bar.fill"
        case .settings: return "gearshape"
        }
    }
}

// MARK: - Main View

struct NextPageView: View {
    @State private var plants: [Plant]
    @State private var selectedPlant: Plant?
    @State private var showCheckIn = false
    @State private var selectedTab: TabSelection = .home

    let gridSize = 4

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
                JournalingView()
                    .tag(TabSelection.journaling)
                    .tabItem {
                        VStack {
                            Image(systemName: TabSelection.journaling.systemImage).font(.title2)
                            Text(TabSelection.journaling.rawValue).font(.caption)
                        }
                        .scaleEffect(selectedTab == .journaling ? 1.2 : 1.0)
                        .fontWeight(selectedTab == .journaling ? .bold : .regular)
                        .animation(.spring(), value: selectedTab)
                    }

                ForestGridView(plants: $plants, selectedPlant: $selectedPlant)
                    .tag(TabSelection.home)
                    .tabItem {
                        VStack {
                            Image(systemName: TabSelection.home.systemImage).font(.title2)
                            Text(TabSelection.home.rawValue).font(.caption)
                        }
                        .scaleEffect(selectedTab == .home ? 1.2 : 1.0)
                        .fontWeight(selectedTab == .home ? .bold : .regular)
                        .animation(.spring(), value: selectedTab)
                    }

                StatsView()
                    .tag(TabSelection.stats)
                    .tabItem {
                        VStack {
                            Image(systemName: TabSelection.stats.systemImage).font(.title2)
                            Text(TabSelection.stats.rawValue).font(.caption)
                        }
                        .scaleEffect(selectedTab == .stats ? 1.2 : 1.0)
                        .fontWeight(selectedTab == .stats ? .bold : .regular)
                        .animation(.spring(), value: selectedTab)
                    }

                SettingsView()
                    .tag(TabSelection.settings)
                    .tabItem {
                        VStack {
                            Image(systemName: TabSelection.settings.systemImage).font(.title2)
                            Text(TabSelection.settings.rawValue).font(.caption)
                        }
                        .scaleEffect(selectedTab == .settings ? 1.2 : 1.0)
                        .fontWeight(selectedTab == .settings ? .bold : .regular)
                        .animation(.spring(), value: selectedTab)
                    }
            }
            .sheet(item: $selectedPlant) { plant in
                if let idx = plants.firstIndex(where: { $0.id == plant.id }) {
                    HabitCheckInView(plant: $plants[idx])
                }
            }
            .navigationBarBackButtonHidden(true)
        }
    }

    // MARK: - Forest Background View
    struct BackgroundGridView: View {
        let tileSize: CGFloat = 100

        var body: some View {
            GeometryReader { geometry in
                let rows = Int(ceil(geometry.size.height / tileSize))
                let cols = Int(ceil(geometry.size.width / tileSize))
                ForEach(0..<rows, id: \.self) { row in
                    ForEach(0..<cols, id: \.self) { col in
                        let imageName = (row + col) % 2 == 0 ? "grass_tile1" : "grass_tile2"
                        Image(imageName)
                            .resizable()
                            .frame(width: tileSize, height: tileSize)
                            .position(
                                x: CGFloat(col) * tileSize + tileSize / 2,
                                y: CGFloat(row) * tileSize + tileSize / 2
                            )
                    }
                }
            }
            .ignoresSafeArea()
        }
    }

    // MARK: - Grid View
    struct ForestGridView: View {
        @Binding var plants: [Plant]
        @Binding var selectedPlant: Plant?

        let gridSize = 4
        let columns: [GridItem] = Array(repeating: .init(.fixed(100)), count: 4)

        var body: some View {
            ZStack {
                BackgroundGridView()

                VStack(spacing: 0) {
                    Text("Your Forest")
                        .font(.system(size: 34, weight: .heavy, design: .rounded))
                        .foregroundColor(.black)
                        .padding(.top, 16)

                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(0..<(gridSize * gridSize), id: \.self) { index in
                                let row = index / gridSize
                                let col = index % gridSize
                                let pos = GridPosition(row: row, col: col)

                                if let plant = plants.first(where: { $0.position == pos }) {
                                    PlantView(plant: plant)
                                        .onTapGesture {
                                            if !hasCheckedInToday(plant: plant) {
                                                selectedPlant = plant
                                            }
                                        }
                                } else {
                                    GrassTileView()
                                }
                            }
                        }
                        .padding(.bottom, 40)
                        .padding(.horizontal, 16)
                    }
                }
            }
        }

        func hasCheckedInToday(plant: Plant) -> Bool {
            guard let last = plant.lastCheckInDate else { return false }
            return Calendar.current.isDateInToday(last)
        }
    }

    // MARK: - Plant View
    struct PlantView: View {
        let plant: Plant
        @State private var arrowOffset: CGFloat = -12

        var body: some View {
            ZStack {
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

                if Calendar.current.isDateInToday(plant.lastCheckInDate ?? .distantPast) {
                    Color.black.opacity(0.3)
                        .frame(width: 100, height: 100)
                        .cornerRadius(12)
                        .overlay(
                            Text("✅")
                                .font(.caption)
                                .foregroundColor(.white)
                        )
                }
            }
            .frame(width: 100, height: 100)
            .onAppear {
                animateArrow()
            }
        }

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
            Color.clear
                .frame(width: 100, height: 100)
        }
    }

    // MARK: - Check-In View
    struct HabitCheckInView: View {
        @Binding var plant: Plant
        @Environment(\.dismiss) var dismiss

        var body: some View {
            VStack(spacing: 24) {
                Spacer()

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
                    Button {
                        plant.state = .sprout
                        plant.growthLevel += 1
                        plant.lastCheckInDate = Date()
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

                    Button {
                        plant.state = .wilt
                        plant.lastCheckInDate = Date()
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

