import Foundation

struct ConfigService {
    static let shared = ConfigService()
    
    // App Group ID
    static let appGroupId = "group.com.zidankazi.sage"
    
    // Keys
    private let apiKeyKey = "OPENAI_API_KEY"
    
    var apiKey: String {
        // 1. Try App Group (Shared)
        if let sharedDefaults = UserDefaults(suiteName: Self.appGroupId),
           let key = sharedDefaults.string(forKey: apiKeyKey), !key.isEmpty {
            return key
        }
        
        // 2. Fallback to bundled Config.plist
        return getBundledConfigValue(forKey: "OpenAIAPIKey") ?? ""
    }
    
    var model: String {
        getBundledConfigValue(forKey: "DefaultModel") ?? "gpt-3.5-turbo"
    }
    
    var maxTokens: Int? {
        if let tokensString = getBundledConfigValue(forKey: "MaxTokens"),
           let tokens = Int(tokensString) {
            return tokens
        }
        return nil
    }
    
    var temperature: Double? {
        if let tempString = getBundledConfigValue(forKey: "Temperature"),
           let temp = Double(tempString) {
            return temp
        }
        return nil
    }
    
    var isConfigured: Bool {
        !apiKey.isEmpty
    }
    
    // MARK: - App Group Sync
    
    /// Call this from the Main App on launch to sync the hardcoded key to the App Group
    func syncToAppGroup() {
        guard let sharedDefaults = UserDefaults(suiteName: Self.appGroupId) else { return }
        
        // Read from local bundle
        if let localKey = getBundledConfigValue(forKey: "OpenAIAPIKey"), !localKey.isEmpty {
            sharedDefaults.set(localKey, forKey: apiKeyKey)
            print("ConfigService: Synced API Key to App Group")
        }
    }
    
    // MARK: - Internal
    
    private func getBundledConfigValue(forKey key: String) -> String? {
        guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: Any] else {
            return nil
        }
        return dict[key] as? String
    }
}
