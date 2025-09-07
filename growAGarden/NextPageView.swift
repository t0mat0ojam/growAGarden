import SwiftUI

struct NextPageView: View {
    // Optional data you can use later
    var habits: [String] = []

    // Defaulted init lets you call NextPageView() or NextPageView(habits: ...)
    init(habits: [String] = []) {
        self.habits = habits
    }

    var body: some View {
        ZStack {
            // Your Tiled map as the screen background
            InteractiveTiledWorldView(mapName: "village_map", displayScale: 3)
                .ignoresSafeArea()

            // Put any overlay UI here if you want
            // VStack { Spacer(); Text("Trees: \(habits.count)") }
        }
    }
}

