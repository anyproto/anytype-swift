import Foundation

protocol ChatMessageLimitsDateProviderProtocol: AnyObject, Sendable {
    func currentDate() -> Date
}

final class ChatMessageLimitsDateProvider: ChatMessageLimitsDateProviderProtocol, Sendable {
    func currentDate() -> Date {
        Date()
    }
}

extension Container {
    var chatDateProvider: Factory<any ChatMessageLimitsDateProviderProtocol> {
        self { ChatMessageLimitsDateProvider() }
    }
}
