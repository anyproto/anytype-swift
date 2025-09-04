import Foundation

protocol ChatCollectionInteractionProviderProtocol {
    func flashMessage(messageId: String)
}

final class ChatCollectionInteractionProvider: ChatCollectionInteractionProviderProtocol {
    
    private var flashMessageProvider: (_ messageId: String) -> Void
    private var scrollToProvider: (_ messageId: String) -> Void
    
    init(flashMessageProvider: @escaping (_: String) -> Void, scrollToProvider: @escaping (_: String) -> Void) {
        self.flashMessageProvider = flashMessageProvider
        self.scrollToProvider = scrollToProvider
    }
    
    func flashMessage(messageId: String) {
        flashMessageProvider(messageId)
    }
    
    func scrollTo(messageId: String) {
        scrollToProvider(messageId)
    }
}
