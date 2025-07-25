import SwiftUI

// MARK: - HabitCalendarCardView
/// A subview that displays a single habit's name, calendar bar, and completion buttons.
struct HabitCalendarCardView: View {
    let habit: Habit
    @ObservedObject var firebaseManager: FirebaseManager
    @ObservedObject var authManager: AuthManager
    
    @State private var showingAlert: Bool = false
    @State private var alertMessage: String = ""

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
                    }
                }
                .padding(.vertical, 5)
            }
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
