import SwiftUI

// MARK: - DBHabit Model
struct DBHabit: Identifiable, Codable, Equatable {
    let id: String
    let habit_name: String
}

// MARK: - ContentView
struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var habits: [DBHabit] = []
    @State private var newHabit: String = ""
    @State private var showNextPage: Bool = false
    @State private var isLoading: Bool = false
    
    // Default habits to show immediately
    private let defaultHabits: [DBHabit] = [
        DBHabit(id: "1", habit_name: "Sleep for 8 hours"),
        DBHabit(id: "2", habit_name: "Read for 30 minutes"),
        DBHabit(id: "3", habit_name: "Workout for 30 minutes")
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    gradient: Gradient(colors: [Color(.systemMint).opacity(0.2),
                                                Color(.systemTeal).opacity(0.07)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    
                    // Title
                    Text("Habits")
                        .font(.system(size: 38, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                        .padding(.bottom, 10)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                    
                    // Habits list
                    ForEach(habits.indices, id: \.self) { index in
                        let habit = habits[index]
                        HStack {
                            Text(habit.habit_name)
                                .font(.system(size: 20, weight: .medium, design: .rounded))
                                .foregroundColor(.primary)
                                .padding(.vertical, 8)
                                .padding(.leading, 18)
                            
                            Spacer()
                            
                            Button {
                                Task {
                                    let habitToDelete = habits[index]
                                    await authManager.deleteHabit(habitToDelete)
                                    await loadHabits()
                                }
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundColor(.pink)
                                    .padding(.trailing, 16)
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.white.opacity(0.86))
                                .shadow(color: Color(.systemTeal).opacity(0.12), radius: 8, x: 0, y: 4)
                        )
                        .padding(.horizontal, 20)
                        .padding(.vertical, 2)
                    }
                    
                    // Add habit
                    HStack {
                        TextField("Add new habit...", text: $newHabit)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemGray6).opacity(0.97))
                            )
                            .font(.system(size: 18, design: .rounded))
                        
                        Button {
                            let trimmed = newHabit.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard !trimmed.isEmpty else { return }
                            Task {
                                await addHabit(name: trimmed)
                            }
                        } label: {
                            if isLoading {
                                ProgressView()
                                    .frame(width: 28, height: 28)
                            } else {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 28))
                            }
                        }
                        .foregroundColor(Color(.systemMint))
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 12)
                    
                    Spacer()
                    
                    // "Go" button
                    Button {
                        showNextPage = true
                    } label: {
                        Text("Go")
                            .font(.system(size: 22, weight: .semibold, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(.systemTeal).opacity(0.75),
                                                                Color(.systemMint).opacity(0.8)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(15)
                            .shadow(color: Color(.systemTeal).opacity(0.12), radius: 8, x: 0, y: 3)
                    }
                    .padding(.horizontal, 48)
                    .padding(.bottom, 30)
                    .navigationDestination(isPresented: $showNextPage) {
                        NextPageView(habits: habits.map { $0.habit_name })
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            // Show default habits immediately
            habits = defaultHabits
        }
        .task {
            await loadHabits()
        }
    }
    
    // MARK: - Helper Methods
    @MainActor
    private func loadHabits() async {
        guard authManager.isLoggedIn else { return }
        
        let fetched = await authManager.fetchHabits()
        
        // Merge default habits with fetched habits (avoid duplicates)
        var merged = defaultHabits
        for habit in fetched {
            if !merged.contains(where: { $0.habit_name == habit.habit_name }) {
                merged.append(habit)
            }
        }
        habits = merged
    }
    
    @MainActor
    private func addHabit(name: String) async {
        isLoading = true
        
        // 1️⃣ Optimistically add a temporary habit
        let tempHabit = DBHabit(id: UUID().uuidString, habit_name: name)
        habits.append(tempHabit)
        newHabit = ""
        
        // 2️⃣ Save to Supabase
        await authManager.saveHabit(name: name)
        
        // 3️⃣ Fetch all habits from Supabase
        let fetched = await authManager.fetchHabits()
        
        // 4️⃣ Merge fetched habits with local habits, avoiding duplicates by habit_name
        var merged: [DBHabit] = []
        
        // Add all unique habits from local + fetched
        for habit in habits + fetched {
            if !merged.contains(where: { $0.habit_name == habit.habit_name }) {
                merged.append(habit)
            }
        }
        
        habits = merged
        isLoading = false
    }

}
