import Foundation
import SwiftData

@MainActor
class DataController {
    static let shared = DataController()
    
    let container: ModelContainer
    
    private init() {
        do {
            let schema = Schema([
                ChatHistoryItem.self
            ])
            
            // Point to App Group container
            let modelConfiguration: ModelConfiguration
            if let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: ConfigService.appGroupId) {
                let databaseURL = groupURL.appendingPathComponent("sage.store")
                modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false, allowsSave: true)
                // Note: SwiftData config usually takes url in init, but as of iOS 17 it handles group containers if specified correctly.
                // However, explicit URL is safest for extensions.
                // modelConfiguration = ModelConfiguration(url: databaseURL) 
                // Let's stick to simple init for now and rely on entitlements, 
                // but usually for sharing we need to specify the url explicitly.
                
                // Explicitly setting URL to shared container
                let config = ModelConfiguration(url: databaseURL)
                container = try ModelContainer(for: schema, configurations: [config])
            } else {
                // Fallback for previews/testing if group not found
                print("⚠️ App Group not found, falling back to local storage")
                modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
                container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            }
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
}
