import UIKit
import Messages
import SwiftUI

/// Main view controller for the Sage iMessage extension.
/// Bridges MSMessagesAppViewController to SwiftUI and handles presentation style changes.
class MessagesViewController: MSMessagesAppViewController {
    
    // MARK: - Properties
    
    /// The SwiftUI hosting controller
    private var hostingController: UIHostingController<AnyView>?
    
    /// Shared state for the chat interface
    private let chatState = ChatState()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        let contentView = ContentView(
            chatState: chatState,
            presentationStyle: presentationStyle,
            onRequestExpand: { [weak self] in
                self?.requestPresentationStyle(.expanded)
            },
            onSendToChat: { [weak self] message in
                self?.insertMessage(message)
            }
        )
        
        let hostingController = UIHostingController(rootView: AnyView(contentView))
        self.hostingController = hostingController
        
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
    
    // MARK: - Presentation Style
    
    override func willBecomeActive(with conversation: MSConversation) {
        super.willBecomeActive(with: conversation)
        
        // Extract selected message text if available
        if let selectedMessage = conversation.selectedMessage,
           let layout = selectedMessage.layout as? MSMessageTemplateLayout {
            chatState.selectedContext = layout.caption ?? layout.subcaption
        }
    }
    
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        super.willTransition(to: presentationStyle)
        updateUI(for: presentationStyle)
    }
    
    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        super.didTransition(to: presentationStyle)
    }
    
    // MARK: - Private Methods
    
    private func updateUI(for presentationStyle: MSMessagesAppPresentationStyle) {
        let contentView = ContentView(
            chatState: chatState,
            presentationStyle: presentationStyle,
            onRequestExpand: { [weak self] in
                self?.requestPresentationStyle(.expanded)
            },
            onSendToChat: { [weak self] message in
                self?.insertMessage(message)
            }
        )
        hostingController?.rootView = AnyView(contentView)
    }
    
    /// Inserts a message into the conversation
    private func insertMessage(_ text: String) {
        guard let conversation = activeConversation else { return }
        
        let message = MSMessage()
        let layout = MSMessageTemplateLayout()
        layout.caption = text
        message.layout = layout
        
        conversation.insert(message) { [weak self] error in
            if let error = error {
                self?.chatState.errorMessage = "Failed to send: \(error.localizedDescription)"
            } else {
                self?.chatState.lastSentMessage = text
            }
        }
    }
}
