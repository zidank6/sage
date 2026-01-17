import Foundation

/// Manages daily message limits and usage tracking
@Observable
class UsageService {
    static let shared = UsageService()
    
    // Config
    private let dailyLimit = 30
    private let storageKey = "sage_daily_count"
    private let resetKey = "sage_last_reset_date"
    
    // State
    var usedCount: Int = 0
    
    // Dependencies
    private var isPremium: Bool {
        SubscriptionService.shared.isPremium
    }
    
    init() {
        checkReset()
        usedCount = UserDefaults.standard.integer(forKey: storageKey)
    }
    
    // MARK: - Public API
    
    var remaining: Int {
        if isPremium { return 999 } // Visual indicator for unlimited
        return max(0, dailyLimit - usedCount)
    }
    
    var isLimitReached: Bool {
        if isPremium { return false }
        return usedCount >= dailyLimit
    }
    
    /// Attempt to use a credit. Returns true if allowed, false if limit reached.
    func increment() -> Bool {
        // Reset check first
        checkReset()
        
        // Premium bypasses limits
        if isPremium {
            return true
        }
        
        // Check limit
        if usedCount >= dailyLimit {
            return false
        }
        
        // Increment
        usedCount += 1
        UserDefaults.standard.set(usedCount, forKey: storageKey)
        return true
    }
    
    // MARK: - Internal Logic
    
    private func checkReset() {
        let now = Date()
        let lastReset = UserDefaults.standard.object(forKey: resetKey) as? Date ?? Date.distantPast
        
        let calendar = Calendar.current
        if !calendar.isDate(now, inSameDayAs: lastReset) {
            // It's a new day!
            usedCount = 0
            UserDefaults.standard.set(usedCount, forKey: storageKey)
            UserDefaults.standard.set(now, forKey: resetKey)
        }
    }
}
