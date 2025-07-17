import SwiftUI

struct StatsView: View {
    var body: some View {
        VStack {
            Text("Stats")
                .font(.largeTitle)
                .padding()
            
            Text("This is where your habit statistics will be displayed.")
                .font(.body)
                .padding()
            
            Spacer()
        }
        .navigationTitle("Stats")
    }
}
