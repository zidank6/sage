import Foundation

/// Service for loading configuration from bundled Config.plist
@Observable
class ConfigService {
    static let shared = ConfigService()
    
    private(set) var apiKey: String = ""
    private(set) var model: String = "gpt-4o"
    private(set) var maxTokens: Int = 500
    private(set) var temperature: Double = 0.7
    
    private init() {
        loadConfig()
    }
    
    /// Load configuration from bundled Config.plist
    private func loadConfig() {
        guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: Any] else {
            print("⚠️ Config.plist not found. API key will be empty.")
            return
        }
        
        apiKey = dict["OpenAIAPIKey"] as? String ?? ""
        model = dict["DefaultModel"] as? String ?? "gpt-4o"
        maxTokens = dict["MaxTokens"] as? Int ?? 500
        temperature = dict["Temperature"] as? Double ?? 0.7
        
        // Security: Never log the full API key
        if !apiKey.isEmpty {
            let prefix = String(apiKey.prefix(8))
            print("✅ Config loaded. API key starts with: \(prefix)...")
        } else {
            print("⚠️ API key is empty in Config.plist")
        }
    }
    
    /// Check if configuration is valid for API calls
    var isConfigured: Bool {
        !apiKey.isEmpty
    }
}
