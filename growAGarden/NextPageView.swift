import SwiftUI

<<<<<<< HEAD
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
=======
// MARK: - HabitCalendarCardView
/// A subview that displays a single habit's name, calendar bar, and completion buttons.
struct HabitCalendarCardView: View {
    let habit: Habit
    @ObservedObject var firebaseManager: FirebaseManager
    @ObservedObject var authManager: AuthManager
    
    @State private var showingAlert: Bool = false
    @State private var alertMessage: String = ""
>>>>>>> tamon

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(habit.name)
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
                .padding(.bottom, 5)

            // Calendar Bar
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) { // Small spacing between daily boxes
                    // Iterate for the last 30 days (from today backwards)
                    ForEach(0..<30) { i in
                        let date = Calendar.current.date(byAdding: .day, value: -i, to: Date())!
                        let dateString = DateFormatter.yyyyMMdd.string(from: date)
                        let isToday = Calendar.current.isDate(date, inSameDayAs: Date())

                        let completionStatus = habit.completions[dateString]

                        let color: Color
                        if isToday {
                            color = .orange // Orange for today
                        } else if completionStatus == true {
                            color = .green // Green for completed
                        } else {
                            // Red for skipped or no entry (implies not completed)
                            color = .red
                        }

<<<<<<< HEAD
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
=======
                        Rectangle()
                            .fill(color)
                            .frame(width: 20, height: 20) // Size of each day box
                            .cornerRadius(4) // Rounded corners for boxes
                            .overlay(
                                Text(date.formatted(.dateTime.day())) // Display day number
                                    .font(.caption2)
                                    .foregroundColor(.white)
                                    .opacity(0.8)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 0.5) // Subtle border
                            )
>>>>>>> tamon
                    }
                }
                .padding(.vertical, 5)
            }
<<<<<<< HEAD
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

                    if plant.state == .wilt {
                        // Wilt state: show emoji
                        Text("🥀")
                            .font(.system(size: 40))
                            .shadow(color: .black.opacity(0.1), radius: 2, x: 1, y: 1)
                    } else {
                        // Growing states: show the image asset
                        Image(imageNameForGrowth(plant))
                            .resizable()
                            .frame(width: 40, height: 40)
                            .shadow(color: .black.opacity(0.1), radius: 2, x: 1, y: 1)
                    }
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

        // This is now a simple string-returning function, not a ViewBuilder
        func imageNameForGrowth(_ plant: Plant) -> String {
            switch (plant.state, plant.growthLevel) {
            case (.seed, _):
                return "tree_1" // sprout
            case (.sprout, 0):
                return "tree_2" // small tree
            case (.sprout, 1...):
                return "tree_3" // big tree or further stages
            default:
                return "tree_1"
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
=======
            .frame(maxWidth: .infinity)
            
            // Completion Buttons for today
            HStack(spacing: 20) {
                Button(action: {
                    Task {
                        // Safely unwrap the userId and habitId before calling the function
                        guard let id = habit.id, let userId = authManager.userId else {
                            alertMessage = "Error: User not authenticated."
                            showingAlert = true
                            return
                        }
                        
                        await firebaseManager.markHabitCompletion(habitId: id, completed: true, userId: userId)
                        if let msg = firebaseManager.message {
                            alertMessage = msg
                            showingAlert = true
                        }
                    }
                }) {
                    Text("Yes ✅")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.green.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(color: Color.green.opacity(0.15), radius: 4, x: 0, y: 2)
>>>>>>> tamon
                }

                Button(action: {
                    Task {
                        // Safely unwrap the userId and habitId before calling the function
                        guard let id = habit.id, let userId = authManager.userId else {
                            alertMessage = "Error: User not authenticated."
                            showingAlert = true
                            return
                        }
                        
                        // This is the call that was previously missing the 'userId' parameter.
                        await firebaseManager.markHabitCompletion(habitId: id, completed: false, userId: userId)
                        if let msg = firebaseManager.message {
                            alertMessage = msg
                            showingAlert = true
                        }
                    }
                }) {
                    Text("No ❌")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.gray.opacity(0.5))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(color: Color.gray.opacity(0.15), radius: 4, x: 0, y: 2)
                }
            }
            .frame(maxWidth: .infinity) // Center the buttons
            .padding(.top, 10)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.86))
                .shadow(color: Color(.systemTeal).opacity(0.12), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal, 20)
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Info"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
}

