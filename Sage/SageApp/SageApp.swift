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
        TabView {
            HomeView()
                .tabItem {
                    Label("Sage", systemImage: "sparkles")
                }
            
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock")
                }
            
            SavedView()
                .tabItem {
                    Label("Saved", systemImage: "bookmark")
                }
        }
    }
}

struct HomeView: View {
    @State private var subService = SubscriptionService.shared
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Spacer()
                
                // Hero
                Image(systemName: "message.badge.waveform.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .shadow(color: .blue.opacity(0.3), radius: 20)
                
                VStack(spacing: 8) {
                    Text("Sage")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                    
                    Text("AI in iMessage")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                
                // Status Card
                VStack(spacing: 12) {
                    HStack {
                        Text("Status")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(subService.isPremium ? "Premium" : "Free")
                            .fontWeight(.semibold)
                            .foregroundStyle(subService.isPremium ? .purple : .secondary)
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Model")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(ConfigService.shared.model) // Assuming accessible or re-expose
                            .font(.system(.body, design: .monospaced))
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 32)
                
                Spacer()
                
                // Action
                // Debug Info
                let dbPath = DataController.shared.container.configurations.first?.url.path ?? "Unknown"
                Text(dbPath)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .onTapGesture {
                        print("DB Path: \(dbPath)")
                    }
                
                Link(destination: URL(string: "sms:")!) {
                    HStack {
                        Image(systemName: "message.fill")
                        Text("Open Messages")
                            .fontWeight(.semibold)
                    }
                    .font(.title3)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.blue)
                    .clipShape(Capsule())
                    .shadow(radius: 10)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 20)
            }
        }
    }
}
