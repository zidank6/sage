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
    @State private var showCopiedToast = false
    
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
                
                // Action Stack
                HStack(spacing: 16) {
                    // Copy Response
                    Button {
                        copyToClipboard(item.response)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "doc.on.doc")
                            Text("Copy")
                        }
                    }
                    .buttonStyle(.bordered)
                    .tint(.blue)
                    .controlSize(.small)
                    
                    // Copy Prompt
                    Button {
                        copyToClipboard(item.prompt)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "quote.bubble")
                            Text("Prompt")
                        }
                    }
                    .buttonStyle(.bordered)
                    .tint(.secondary)
                    .controlSize(.small)
                    
                    // Share
                    ShareLink(item: shareText) {
                        HStack(spacing: 6) {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share")
                        }
                    }
                    .buttonStyle(.bordered)
                    .tint(.secondary)
                    .controlSize(.small)
                }
                .padding(.leading, 4)
                
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
        .overlay(alignment: .bottom) {
            if showCopiedToast {
                Text("Copied!")
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.black.opacity(0.8))
                    .clipShape(Capsule())
                    .padding(.bottom, 50)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                    .zIndex(100)
            }
        }
    }
    
    private var shareText: String {
        "Prompt: \(item.prompt)\n\nSage: \(item.response)"
    }
    
    private func copyToClipboard(_ text: String) {
        UIPasteboard.general.string = text
        withAnimation(.snappy) {
            showCopiedToast = true
        }
        
        // Hide after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showCopiedToast = false
            }
        }
    }
}
