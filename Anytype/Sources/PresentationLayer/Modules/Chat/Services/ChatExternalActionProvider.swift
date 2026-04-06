import Foundation
import SwiftUI

@MainActor
protocol ChatActionProviderHandler: AnyObject {
    func addAttachment(_ attachment: ChatLinkObject, clearInput: Bool)
    func scrollToMessage(messageId: String)
}

struct ChatActionProvider {

    private var handlers = NSMapTable<NSString, AnyObject>.strongToWeakObjects()

    mutating func register(chatId: String, handler: any ChatActionProviderHandler) {
        handlers.setObject(handler as AnyObject, forKey: chatId as NSString)
    }

    private func handler(for chatId: String) -> (any ChatActionProviderHandler)? {
        handlers.object(forKey: chatId as NSString) as? any ChatActionProviderHandler
    }

    @MainActor
    func addAttachment(chatId: String, _ attachment: ChatLinkObject, clearInput: Bool) {
        handler(for: chatId)?.addAttachment(attachment, clearInput: clearInput)
    }

    @MainActor
    func scrollToMessage(chatId: String, messageId: String) {
        handler(for: chatId)?.scrollToMessage(messageId: messageId)
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
