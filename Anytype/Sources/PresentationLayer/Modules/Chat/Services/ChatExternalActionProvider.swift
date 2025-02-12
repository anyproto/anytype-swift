import Foundation
import SwiftUI

@MainActor
protocol ChatActionProviderHandler: AnyObject {
    func createChatWithAttachment(_ attachment: ChatLinkObject)
}

struct ChatActionProvider {
    
    weak var handler: (any ChatActionProviderHandler)?
        
    @MainActor
    func createChatWithAttachment(_ attachment: ChatLinkObject) {
        handler?.createChatWithAttachment(attachment)
    }
}

extension EnvironmentValues {
    @Entry var chatActionProvider: Binding<ChatActionProvider> = .constant(ChatActionProvider())
}
