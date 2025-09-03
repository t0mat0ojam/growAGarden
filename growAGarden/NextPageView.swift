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
    case volunteer = "Volunteer"
    case settings = "Settings"

    var id: String { self.rawValue }

    var systemImage: String {
        switch self {
        case .journaling: return "book.closed"
        case .home: return "leaf.circle.fill"
        case .stats: return "chart.bar.fill"
        case .volunteer: return "hand.raised.fill"
        case .settings: return "gearshape"
        }
    }
}

// MARK: - Time of Day
enum TimeOfDay {
    case morning, afternoon, evening, night

    var skyGradient: [Color] {
        switch self {
        case .morning:
            return [Color(red: 0.9, green: 0.95, blue: 1.0), Color(red: 0.8, green: 0.9, blue: 0.95)]
        case .afternoon:
            return [Color(red: 0.6, green: 0.8, blue: 1.0), Color(red: 0.4, green: 0.7, blue: 0.9)]
        case .evening:
            return [Color(red: 1.0, green: 0.6, blue: 0.4), Color(red: 0.8, green: 0.4, blue: 0.6)]
        case .night:
            return [Color(red: 0.1, green: 0.1, blue: 0.3), Color(red: 0.2, green: 0.1, blue: 0.4)]
        }
    }
}

// MARK: - Floating Particle (fixed: no GeometryProxy)
struct FloatingParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    let color: Color
    let size: CGFloat
    var opacity: Double = 0.6
    let duration: Double

    init(position: CGPoint) {
        self.position = position
        self.color = [Color.white, Color.yellow, Color.green.opacity(0.8)].randomElement() ?? .white
        self.size = CGFloat.random(in: 2...6)
        self.duration = Double.random(in: 8...15)
    }
}

// MARK: - Main View

struct NextPageView: View {
    @State private var plants: [Plant]
    @State private var selectedPlant: Plant?
    @State private var selectedTab: TabSelection = .home
    @State private var timeOfDay: TimeOfDay = .morning

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
                        Label(TabSelection.journaling.rawValue, systemImage: TabSelection.journaling.systemImage)
                    }

                EnhancedForestGridView(plants: $plants, selectedPlant: $selectedPlant, timeOfDay: timeOfDay)
                    .tag(TabSelection.home)
                    .tabItem {
                        Label(TabSelection.home.rawValue, systemImage: TabSelection.home.systemImage)
                    }

                StatsView()
                    .tag(TabSelection.stats)
                    .tabItem {
                        Label(TabSelection.stats.rawValue, systemImage: TabSelection.stats.systemImage)
                    }

                VolunteerView()
                    .tag(TabSelection.volunteer)
                    .tabItem {
                        Label(TabSelection.volunteer.rawValue, systemImage: TabSelection.volunteer.systemImage)
                    }

                SettingsView()
                    .tag(TabSelection.settings)
                    .tabItem {
                        Label(TabSelection.settings.rawValue, systemImage: TabSelection.settings.systemImage)
                    }
            }
            .accentColor(.green)
            .onAppear { updateTimeOfDay() }
            .sheet(item: $selectedPlant) { plant in
                if let idx = plants.firstIndex(where: { $0.id == plant.id }) {
                    HabitCheckInView(plant: $plants[idx])
                }
            }
            .navigationBarBackButtonHidden(true)
        }
    }

    private func updateTimeOfDay() {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6..<12: timeOfDay = .morning
        case 12..<18: timeOfDay = .afternoon
        case 18..<22: timeOfDay = .evening
        default: timeOfDay = .night
        }
    }
}

// MARK: - Enhanced Forest Grid View
struct EnhancedForestGridView: View {
    @Binding var plants: [Plant]
    @Binding var selectedPlant: Plant?
    let timeOfDay: TimeOfDay

    @State private var floatingParticles: [FloatingParticle] = []
    @State private var animationTimer: Timer?
    @State private var cloudOffset1: CGFloat = -100
    @State private var cloudOffset2: CGFloat = -150

    var body: some View {
        GeometryReader { _ in
            ZStack {
                // Dynamic sky background
                LinearGradient(
                    gradient: Gradient(colors: timeOfDay.skyGradient),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                // Animated clouds
                ZStack {
                    // Cloud 1
                    HStack {
                        ForEach(0..<3, id: \.self) { _ in
                            Circle()
                                .fill(Color.white.opacity(0.7))
                                .frame(width: CGFloat.random(in: 20...40))
                        }
                    }
                    .offset(x: cloudOffset1, y: 50)

                    // Cloud 2
                    HStack {
                        ForEach(0..<4, id: \.self) { _ in
                            Circle()
                                .fill(Color.white.opacity(0.5))
                                .frame(width: CGFloat.random(in: 15...35))
                        }
                    }
                    .offset(x: cloudOffset2, y: 100)
                }

                // Animated floating particles
                ForEach(floatingParticles, id: \.id) { particle in
                    Circle()
                        .fill(particle.color)
                        .frame(width: particle.size, height: particle.size)
                        .position(particle.position)
                        .opacity(particle.opacity)
                        .animation(.linear(duration: particle.duration), value: particle.position)
                }

                ScrollView {
                    VStack(spacing: 25) {
                        // Header
                        VStack(spacing: 12) {
                            HStack {
                                ForEach(0..<3, id: \.self) { _ in
                                    Image(systemName: "leaf.fill")
                                        .foregroundColor(.green)
                                        .font(.title3)
                                }

                                Text("Your Forest")
                                    .font(.system(size: 32, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)

                                ForEach(0..<3, id: \.self) { _ in
                                    Image(systemName: "leaf.fill")
                                        .foregroundColor(.green)
                                        .font(.title3)
                                        .scaleEffect(x: -1)
                                }
                            }

                            // Progress indicator
                            ProgressView(value: completionRate) {
                                Text("Forest Health: \(Int(completionRate * 100))%")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            .progressViewStyle(LinearProgressViewStyle(tint: .green))
                            .padding(.horizontal, 40)
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)

                        // Plant grid
                        LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: 12), count: 4), spacing: 16) {
                            ForEach(0..<(4 * 4), id: \.self) { index in
                                let row = index / 4
                                let col = index % 4
                                let pos = GridPosition(row: row, col: col)

                                if let plant = plants.first(where: { $0.position == pos }) {
                                    EnhancedPlantView(plant: plant)
                                        .onTapGesture {
                                            if !hasCheckedInToday(plant: plant) {
                                                selectedPlant = plant
                                            }
                                        }
                                } else {
                                    EmptyGrassTile()
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)

                        // Footer
                        if completionRate > 0.7 {
                            VStack(spacing: 8) {
                                Text("🌟 Your forest is thriving! 🌟")
                                    .font(.headline)
                                    .foregroundColor(.primary)

                                Text("Keep up the amazing work!")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.yellow.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                                    )
                            )
                            .padding(.horizontal)
                        }
                    }
                }
            }
        }
        .onAppear {
            startParticleAnimation()
            animateClouds()
        }
        .onDisappear {
            stopParticleAnimation()
        }
    }

    private var completionRate: Double {
        guard !plants.isEmpty else { return 0 }
        let healthyPlants = plants.filter { $0.state != .wilt }.count
        return Double(healthyPlants) / Double(plants.count)
    }

    private func hasCheckedInToday(plant: Plant) -> Bool {
        guard let last = plant.lastCheckInDate else { return false }
        return Calendar.current.isDateInToday(last)
    }

    // MARK: - Particle Animation
    private func startParticleAnimation() {
        animationTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { _ in
            addFloatingParticle()
        }
        for _ in 0..<3 { addFloatingParticle() }
    }

    private func stopParticleAnimation() {
        animationTimer?.invalidate()
    }

    private func addFloatingParticle() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height

        let particle = FloatingParticle(
            position: CGPoint(
                x: CGFloat.random(in: 0...screenWidth),
                y: screenHeight + 20
            )
        )

        floatingParticles.append(particle)

        // Animate particle upward
        withAnimation(.linear(duration: particle.duration)) {
            if let index = floatingParticles.firstIndex(where: { $0.id == particle.id }) {
                floatingParticles[index].position.y = -50
                floatingParticles[index].opacity = 0
            }
        }

        // Remove particle after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + particle.duration) {
            floatingParticles.removeAll { $0.id == particle.id }
        }
    }

    private func animateClouds() {
        withAnimation(Animation.linear(duration: 20).repeatForever(autoreverses: false)) {
            cloudOffset1 = UIScreen.main.bounds.width + 100
        }

        withAnimation(Animation.linear(duration: 25).repeatForever(autoreverses: false)) {
            cloudOffset2 = UIScreen.main.bounds.width + 150
        }
    }
}

// MARK: - Enhanced Plant View
struct EnhancedPlantView: View {
    let plant: Plant
    @State private var isGlowing = false
    @State private var bobOffset: CGFloat = 0
    @State private var sparkleOpacity: Double = 0

    var body: some View {
        ZStack {
            // Tile background with subtle pattern
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.3, green: 0.7, blue: 0.3).opacity(0.3),
                            Color(red: 0.2, green: 0.5, blue: 0.2).opacity(0.5)
                        ],
                        center: .center,
                        startRadius: 20,
                        endRadius: 60
                    )
                )
                .frame(width: 80, height: 80)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [Color.green.opacity(0.3), Color.mint.opacity(0.5)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )

            VStack(spacing: 2) {
                // Interaction indicator
                if !hasCheckedInToday() {
                    Image(systemName: "hand.tap")
                        .foregroundColor(.orange)
                        .font(.caption2)
                        .offset(y: bobOffset)
                        .opacity(0.8)
                }

                // Plant visualization
                ZStack {
                    if plant.state == .wilt {
                        VStack {
                            Text("🥀")
                                .font(.system(size: 32))
                                .grayscale(0.8)
                                .overlay(
                                    Rectangle()
                                        .fill(Color.black.opacity(0.2))
                                        .blendMode(.multiply)
                                )
                        }
                    } else {
                        VStack(spacing: 1) {
                            // Growth sparkles for healthy plants
                            if plant.state == .sprout && plant.growthLevel > 0 {
                                HStack(spacing: 2) {
                                    ForEach(0..<min(plant.growthLevel, 3), id: \.self) { _ in
                                        Image(systemName: "sparkle")
                                            .foregroundColor(.yellow)
                                            .font(.system(size: 8))
                                            .opacity(sparkleOpacity)
                                    }
                                }
                                .animation(
                                    Animation.easeInOut(duration: 1.5)
                                        .repeatForever(autoreverses: true),
                                    value: sparkleOpacity
                                )
                            }

                            // Main plant image
                            Image(imageNameForGrowth(plant))
                                .resizable()
                                .frame(width: plantSize(plant), height: plantSize(plant))
                                .shadow(color: .black.opacity(0.2), radius: 4, x: 2, y: 2)
                                .scaleEffect(isGlowing ? 1.05 : 1.0)
                                .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isGlowing)
                        }
                    }

                    // Check-in overlay
                    if hasCheckedInToday() {
                        ZStack {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 24, height: 24)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: 2)
                                )

                            Image(systemName: "checkmark")
                                .foregroundColor(.white)
                                .font(.system(size: 12, weight: .bold))
                        }
                        .offset(x: 25, y: -25)
                        .shadow(color: .green.opacity(0.5), radius: 4)
                    }
                }

                // Habit name
                Text(plant.habit)
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.horizontal, 4)
            }
        }
        .frame(width: 80, height: 80)
        .onAppear { startAnimations() }
    }

    private func hasCheckedInToday() -> Bool {
        guard let last = plant.lastCheckInDate else { return false }
        return Calendar.current.isDateInToday(last)
    }

    private func startAnimations() {
        withAnimation {
            isGlowing = true
            sparkleOpacity = 1.0
        }
        withAnimation(Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
            bobOffset = -3
        }
    }

    // Fixed: make switch exhaustive with a default
    private func plantSize(_ plant: Plant) -> CGFloat {
        switch (plant.state, plant.growthLevel) {
        case (.seed, _): return 20
        case (.sprout, 0): return 25
        case (.sprout, 1): return 30
        case (.sprout, 2...): return 35
        case (.wilt, _): return 28
        default: return 28 // safety for unexpected values (e.g., negative growthLevel)
        }
    }

    private func imageNameForGrowth(_ plant: Plant) -> String {
        switch (plant.state, plant.growthLevel) {
        case (.seed, _): return "tree_1"
        case (.sprout, 0): return "tree_2"
        case (.sprout, 1): return "tree_3"
        case (.sprout, 2...): return "tree_4" // ensure your asset name matches
        default: return "tree_1"
        }
    }
}

// MARK: - Empty Grass Tile
struct EmptyGrassTile: View {
    @State private var grassSway: Double = 0

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.green.opacity(0.2),
                            Color.green.opacity(0.4)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 80, height: 80)

            // Subtle grass pattern
            VStack {
                Spacer()
                HStack(spacing: 3) {
                    ForEach(0..<4, id: \.self) { index in
                        Rectangle()
                            .fill(Color.green.opacity(0.6))
                            .frame(width: 2, height: CGFloat.random(in: 8...15))
                            .rotationEffect(.degrees(grassSway + Double(index) * 2))
                    }
                }
                .padding(.bottom, 8)
            }

            // Soft inner glow
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.green.opacity(0.3), lineWidth: 1)
                .frame(width: 80, height: 80)
        }
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                grassSway = 5
            }
        }
    }
}

// MARK: - Enhanced Check-In View (with quantity + impact logging)
struct HabitCheckInView: View {
    @Binding var plant: Plant
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject private var impactStore = ImpactStore.shared
    private let calc = ImpactCalculator()
    
    // UI State for inputs
    @State private var km: Double = 2.0
    @State private var hours: Double = 1.0
    @State private var bottles: Int = 1
    @State private var meals: Int = 1
    @State private var loads: Int = 1
    @State private var countUnknown: Int = 1
    @State private var showConfetti = false
    
    private var kind: HabitKind {
        calc.kind(for: plant.habit)
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.9, green: 0.95, blue: 1.0),
                    Color(red: 0.8, green: 0.9, blue: 0.95)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 22) {
                Spacer(minLength: 8)
                
                // Title + plant
                VStack(spacing: 10) {
                    Text(plant.habit)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Image(imageNameForGrowth(plant))
                        .resizable()
                        .frame(width: 64, height: 64)
                        .shadow(radius: 4)
                }
                
                // Dynamic input form
                inputForm
                
                // Buttons
                HStack(spacing: 18) {
                    Button(role: .cancel) {
                        plant.state = .wilt
                        plant.lastCheckInDate = Date()
                        dismiss()
                    } label: {
                        labelBox(icon: "xmark.circle.fill", title: "Not yet", colors: [.gray, .secondary])
                    }
                    
                    Button {
                        // Update growth
                        plant.state = .sprout
                        plant.growthLevel += 1
                        plant.lastCheckInDate = Date()
                        
                        // Log impact
                        logImpact()
                        
                        showConfetti = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                            dismiss()
                        }
                    } label: {
                        labelBox(icon: "checkmark.circle.fill", title: "Save", colors: [.green, .mint])
                    }
                }
                .padding(.top, 4)
                
                Spacer(minLength: 8)
            }
            .padding()
            
            if showConfetti { ConfettiView() }
        }
    }
    
    @ViewBuilder
    private var inputForm: some View {
        switch kind {
        case .bike:
            formCard {
                HStack {
                    Image(systemName: "bicycle")
                    Text("How many km did you bike / take public transport?")
                    Spacer()
                }
                Stepper(value: $km, in: 0...200, step: 0.5) {
                    Text(String(format: "%.1f km", km))
                }
            }
        case .ac(let setpoint):
            formCard {
                HStack {
                    Image(systemName: "thermometer.sun")
                    Text(String(format: "AC at %.1f°C — for how many hours today?", setpoint))
                    Spacer()
                }
                Stepper(value: $hours, in: 0...24, step: 0.5) {
                    Text(String(format: "%.1f h", hours))
                }
            }
        case .bottle:
            formCard {
                HStack {
                    Image(systemName: "bottle.fill")
                    Text("Disposable bottles avoided today")
                    Spacer()
                }
                Stepper(value: $bottles, in: 0...100) {
                    Text("\(bottles) bottle(s)")
                }
            }
        case .lunch:
            formCard {
                HStack {
                    Image(systemName: "fork.knife")
                    Text("Meals brought from home today")
                    Spacer()
                }
                Stepper(value: $meals, in: 0...10) {
                    Text("\(meals) meal(s)")
                }
            }
        case .hangDry:
            formCard {
                HStack {
                    Image(systemName: "wind")
                    Text("Loads hang-dried today")
                    Spacer()
                }
                Stepper(value: $loads, in: 0...10) {
                    Text("\(loads) load(s)")
                }
            }
        case .unknown:
            formCard {
                HStack {
                    Image(systemName: "checkmark.circle")
                    Text("Times completed today")
                    Spacer()
                }
                Stepper(value: $countUnknown, in: 1...20) {
                    Text("\(countUnknown) time(s)")
                }
                Text("This habit doesn’t have a calculator yet, but your streak will grow!")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    @ViewBuilder
    private func formCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12, content: content)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.9))
                    .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
            )
            .padding(.horizontal)
    }
    
    private func labelBox(icon: String, title: String, colors: [Color]) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon).font(.system(size: 28))
            Text(title).font(.headline).fontWeight(.semibold)
        }
        .foregroundColor(.white)
        .frame(width: 130, height: 96)
        .background(LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing))
        .cornerRadius(20)
        .shadow(color: colors.first?.opacity(0.4) ?? .black.opacity(0.3), radius: 8, x: 0, y: 4)
    }
    
    private func logImpact() {
        switch kind {
        case .bike:
            impactStore.logBike(habitName: plant.habit, km: km)
        case .ac(let setpoint):
            impactStore.logAC(habitName: plant.habit, setpointC: setpoint, hours: hours)
        case .bottle:
            impactStore.logBottle(habitName: plant.habit, count: bottles)
        case .lunch:
            impactStore.logLunch(habitName: plant.habit, meals: meals)
        case .hangDry:
            impactStore.logHangDry(habitName: plant.habit, loads: loads)
        case .unknown:
            impactStore.logUnknown(habitName: plant.habit, count: countUnknown)
        }
    }
    
    private func imageNameForGrowth(_ plant: Plant) -> String {
        switch (plant.state, plant.growthLevel) {
        case (.seed, _): return "tree_1"
        case (.sprout, 0): return "tree_2"
        case (.sprout, 1): return "tree_3"
        case (.sprout, 2...): return "tree_4"
        default: return "tree_1"
        }
    }
}


// MARK: - Confetti View
struct ConfettiView: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            ForEach(0..<20, id: \.self) { index in
                Circle()
                    .fill([Color.yellow, Color.green, Color.blue, Color.pink].randomElement() ?? Color.yellow)
                    .frame(width: 8, height: 8)
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: animate ? UIScreen.main.bounds.height + 50 : -50
                    )
                    .animation(
                        Animation.easeOut(duration: Double.random(in: 1...3))
                            .delay(Double(index) * 0.1),
                        value: animate
                    )
            }
        }
        .onAppear { animate = true }
    }
}
