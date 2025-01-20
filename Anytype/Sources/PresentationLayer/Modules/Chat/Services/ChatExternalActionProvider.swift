import Foundation
import SwiftUI

@MainActor
protocol ChatActionProviderHandler: AnyObject {
    func addAttachment(_ attachment: ChatLinkObject, clearInput: Bool)
}

struct ChatActionProvider {
    
    weak var handler: (any ChatActionProviderHandler)?
        
    @MainActor
    func addAttachment(_ attachment: ChatLinkObject, clearInput: Bool) {
        handler?.addAttachment(attachment, clearInput: clearInput)
    }
}

extension EnvironmentValues {
    @Entry var chatActionProvider: Binding<ChatActionProvider> = .constant(ChatActionProvider())
}

extension View {
    func chatActionProvider(_ privider: Binding<ChatActionProvider>) -> some View {
        environment(\.chatActionProvider, privider)
    }
}
