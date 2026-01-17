import SwiftUI
import StoreKit

struct UpgradeView: View {
    @Environment(\.dismiss) var dismiss
    @State private var isPurchasing = false
    @State private var error: String?
    
    // Services
    @State private var subService = SubscriptionService.shared
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 12) {
                Image(systemName: "sparkles")
                    .font(.system(size: 60))
                    .foregroundStyle(.blue)
                    .symbolEffect(.bounce, value: isPurchasing)
                
                Text("Unlock Unlimited Sage")
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)
                
                Text("Get unlimited messages, smarter AI answers, and extended responses.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(.top, 30)
            
            // Features Grid
            VStack(spacing: 16) {
                FeatureRow(icon: "infinity", title: "Unlimited Messages", subtitle: "No daily limits")
                FeatureRow(icon: "brain.head.profile", title: "Smarter AI", subtitle: "Powered by GPT-4o")
                FeatureRow(icon: "text.quote", title: "Longer Responses", subtitle: "Detailed answers")
            }
            .padding(.vertical)
            
            Spacer()
            
            // Products
            if subService.products.isEmpty {
                ProgressView()
                    .padding()
            } else {
                VStack(spacing: 12) {
                    ForEach(subService.products) { product in
                        Button {
                            purchase(product)
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(product.displayName)
                                        .font(.headline)
                                    Text(product.description)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                Text(product.displayPrice)
                                    .fontWeight(.bold)
                            }
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                        .disabled(isPurchasing)
                    }
                }
                .padding(.horizontal)
            }
            
            // Restore & Terms
            HStack(spacing: 20) {
                Button("Restore Purchases") {
                    Task {
                        isPurchasing = true
                        await subService.updateSubscriptionStatus()
                        isPurchasing = false
                    }
                }
                .font(.caption)
                
                Link("Deepmind Terms", destination: URL(string: "https://google.com")!)
                    .font(.caption)
            }
            .foregroundStyle(.secondary)
            .padding(.bottom)
        }
        .presentationDetents([.medium, .large])
        .alert("Purchase Failed", isPresented: .constant(error != nil)) {
            Button("OK") { error = nil }
        } message: {
            Text(error ?? "Unknown error")
        }
    }
    
    private func purchase(_ product: Product) {
        Task {
            isPurchasing = true
            do {
                try await subService.purchase(product)
                if subService.isPremium {
                    dismiss()
                }
            } catch {
                self.error = error.localizedDescription
            }
            isPurchasing = false
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal, 30)
    }
}

#Preview {
    UpgradeView()
}
