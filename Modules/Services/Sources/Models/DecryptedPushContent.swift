public struct DecryptedPushContent: Codable {
    public let spaceId: String
    public let type: Int
    public let senderId: String
    public let newMessage: Message
    
    public struct Message: Codable {
        public let chatId: String
        public let msgId: String
        public let text: String
        public let spaceName: String
        public let senderName: String
        public let hasAttachments: Bool
        
        public var hasText: Bool {
            text.isNotEmpty
        }
    }
}
