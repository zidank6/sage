import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: \ChatHistoryItem.timestamp, order: .reverse) private var history: [ChatHistoryItem]
    @State private var subService = SubscriptionService.shared
    
    var body: some View {
        NavigationStack {
            List {
                if history.isEmpty {
                    ContentUnavailableView("No History", systemImage: "clock", description: Text("Your conversations with Sage will appear here."))
                } else {
                    ForEach(visibleHistory) { item in
                        NavigationLink(destination: HistoryDetailView(item: item)) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.prompt)
                                    .font(.headline)
                                    .lineLimit(1)
                                
                                Text(item.response)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                                
                                Text(item.timestamp, format: .dateTime.month().day().hour().minute())
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)
                                    .padding(.top, 2)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
                
                if !subService.isPremium && history.count > 10 {
                    Section {
                        NavigationLink(destination: UpgradeView()) {
                            HStack {
                                Image(systemName: "lock.fill")
                                    .foregroundStyle(.orange)
                                Text("Unlock Unlimited History")
                                    .fontWeight(.medium)
                            }
                        }
                    } footer: {
                        Text("Free users see the last 10 messages.")
                    }
                }
            }
            .navigationTitle("History")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    private var visibleHistory: [ChatHistoryItem] {
        if subService.isPremium {
            return history
        } else {
            return Array(history.prefix(10))
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                // Be careful deleting from the *filtered* visibleHistory vs *full* history
                // offsets are relative to the visible list
                if index < visibleHistory.count {
                    let item = visibleHistory[index]
                    DataController.shared.container.mainContext.delete(item)
                }
            }
        }
    }
}

struct HistoryDetailView: View {
    @Bindable var item: ChatHistoryItem
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Prompt Bubble
                HStack {
                    Spacer()
                    Text(item.prompt)
                        .padding()
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                
                // Response Bubble
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(item.response)
                            .textSelection(.enabled)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    
                    Spacer()
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle(item.timestamp.formatted(date: .abbreviated, time: .shortened))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    item.isBookmarked.toggle()
                } label: {
                    Image(systemName: item.isBookmarked ? "bookmark.fill" : "bookmark")
                }
            }
        }
    }
}
