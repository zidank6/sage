import Foundation
import SwiftData

@Model
final class ChatHistoryItem {
    var prompt: String
    var response: String
    var timestamp: Date
    var isBookmarked: Bool
    
    init(prompt: String, response: String, timestamp: Date = Date(), isBookmarked: Bool = false) {
        self.prompt = prompt
        self.response = response
        self.timestamp = timestamp
        self.isBookmarked = isBookmarked
    }
}
