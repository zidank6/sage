import UIKit
import Messages
import SwiftUI

/// Main view controller for Sage iMessage extension.
class MessagesViewController: MSMessagesAppViewController {
    
    private var hostingController: UIHostingController<AnyView>?
    private let chatState = ChatState()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
    }
    
    private func setupUI() {
        let contentView = CompactView(
            chatState: chatState,
            onSendToChat: { [weak self] message in
                self?.insertRichMessage(message)
            }
        )
        
        let hostingController = UIHostingController(rootView: AnyView(contentView))
        self.hostingController = hostingController
        hostingController.view.backgroundColor = .systemBackground
        
        addChild(hostingController)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hostingController.view)
        
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        hostingController.didMove(toParent: self)
    }
    
    override func willBecomeActive(with conversation: MSConversation) {
        super.willBecomeActive(with: conversation)
        if let selectedMessage = conversation.selectedMessage,
           let layout = selectedMessage.layout as? MSMessageTemplateLayout {
            chatState.selectedContext = layout.caption ?? layout.subcaption
        }
    }
    
    /// Inserts a rich, non-editable message using MSMessageTemplateLayout
    private func insertRichMessage(_ text: String) {
        guard let conversation = activeConversation else { return }
        
        let message = MSMessage()
        let layout = MSMessageTemplateLayout()
        layout.caption = text  // The AI response - non-editable
        layout.subcaption = "via Sage ✨"  // Attribution
        message.layout = layout
        
        // Insert directly into thread (bypasses compose bar - tamper-proof)
        conversation.insert(message) { [weak self] error in
            if let error = error {
                self?.chatState.errorMessage = "Failed: \(error.localizedDescription)"
            } else {
                self?.chatState.messages.removeAll()
            }
        }
    }
}
