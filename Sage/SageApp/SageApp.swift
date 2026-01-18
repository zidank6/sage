import SwiftUI
import SwiftData

@main
struct SageApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(DataController.shared.container)
        }
    }
}

struct ContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "message.badge.waveform")
                .font(.system(size: 60))
                .foregroundStyle(.blue)
            
            Text("Sage")
                .font(.largeTitle.bold())
            
            Text("Open this extension in Messages")
                .foregroundStyle(.secondary)
            
            Text("Messages → Compose → App Drawer → Sage")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
