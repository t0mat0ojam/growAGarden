import SwiftUI

struct CustomizeView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Customize Page")
                    .font(.largeTitle)
                    .padding()
                
                Text("This is a blank page for customization options.")
                    .font(.body)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Customize")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
