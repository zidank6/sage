import SwiftUI
import SwiftData

struct SavedView: View {
    @Query(filter: #Predicate<ChatHistoryItem> { $0.isBookmarked }, sort: \ChatHistoryItem.timestamp, order: .reverse) private var savedItems: [ChatHistoryItem]
    
    var body: some View {
        NavigationStack {
            List {
                if savedItems.isEmpty {
                    ContentUnavailableView("No Saved Items", systemImage: "bookmark", description: Text("Bookmark conversations in History to see them here."))
                } else {
                    ForEach(savedItems) { item in
                        NavigationLink(destination: HistoryDetailView(item: item)) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.prompt)
                                    .font(.headline)
                                    .lineLimit(1)
                                
                                Text(item.response)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
            }
            .navigationTitle("Saved")
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let item = savedItems[index]
                item.isBookmarked = false // Just unbookmark, don't delete from history? 
                // Specification says "Delete option", usually users expect 'delete from saved' to just unsave, 
                // but standard List .onDelete implies destruction.
                // Let's safe choice: Unbookmark them. If they want to delete record, do it in History.
            }
        }
    }
}
