import SwiftUI

struct ContentView: View {
    @State private var habits: [String] = [
        "Sleep for 8 hours",
        "Read for 30 minutes",
        "Workout for 30 minutes"
    ]
    @State private var newHabit: String = ""
    @State private var showNextPage: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Soft background color
                LinearGradient(gradient: Gradient(colors: [Color(.systemMint).opacity(0.2), Color(.systemTeal).opacity(0.07)]), startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                VStack {
                    Spacer()
                    
                    // Title centered with custom font
                    Text("Habits")
                        .font(.system(size: 38, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                        .padding(.bottom, 10)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                    
                    // Habits list as soft rounded cards
                    ForEach(Array(habits.enumerated()), id: \.element) { index, habit in
                        HStack {
                            Text(habit)
                                .font(.system(size: 20, weight: .medium, design: .rounded))
                                .foregroundColor(.primary)
                                .padding(.vertical, 8)
                                .padding(.leading, 18)
                            
                            Spacer()
                            
                            // Delete button
                            Button(action: {
                                habits.remove(at: index)
                            }) {
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

                    // Habit input field
                    HStack {
                        TextField("Add new habit...", text: $newHabit)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemGray6).opacity(0.97))
                            )
                            .font(.system(size: 18, design: .rounded))
                        
                        Button(action: {
                            let trimmed = newHabit.trimmingCharacters(in: .whitespacesAndNewlines)
                            if !trimmed.isEmpty {
                                habits.append(trimmed)
                                newHabit = ""
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(Color(.systemMint))
                                .font(.system(size: 28))
                        }
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
                                LinearGradient(gradient: Gradient(colors: [Color(.systemTeal).opacity(0.75), Color(.systemMint).opacity(0.8)]), startPoint: .leading, endPoint: .trailing)
                            )
                            .foregroundColor(.white)
                            .cornerRadius(15)
                            .shadow(color: Color(.systemTeal).opacity(0.12), radius: 8, x: 0, y: 3)
                    }
                    .padding(.horizontal, 48)
                    .padding(.bottom, 30)
                    .navigationDestination(isPresented: $showNextPage) {
                        NextPageView(habits: habits)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

