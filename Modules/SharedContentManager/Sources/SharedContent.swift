import Foundation

public struct SharedContent: Codable, Sendable {
    public let title: String?
    public let items: [SharedContentItem]
    public let debugInfo: SharedContentDebugInfo
    public var suggestedConversationId: String?

    public init(
        title: String?,
        items: [SharedContentItem],
        debugInfo: SharedContentDebugInfo,
        suggestedConversationId: String? = nil
    ) {
        self.title = title
        self.items = items
        self.debugInfo = debugInfo
        self.suggestedConversationId = suggestedConversationId
    }
}
