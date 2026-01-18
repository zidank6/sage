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
                print("✅ DataController: App Group URL found: \(groupURL.path)")
                let databaseURL = groupURL.appendingPathComponent("sage.store")
                print("✅ DataController: Database URL: \(databaseURL.path)")
                modelConfiguration = ModelConfiguration(url: databaseURL)
                container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            } else {
                // Fallback for previews/testing if group not found
                print("⚠️ DataController: App Group NOT found for ID: \(ConfigService.appGroupId)")
                modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
                container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            }
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
}
