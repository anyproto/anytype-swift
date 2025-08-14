import OrderedCollections
import Services
import AnytypeCore

struct ChatInternalMessageStorage: Sendable {
    // Key - Message id
    private var allMessages = OrderedDictionary<String, ChatMessage>()
    
    func index(messageId: String) -> Int? {
        allMessages.index(forKey: messageId)
    }
    
    var first: ChatMessage? {
        allMessages.values.first
    }
    
    var last: ChatMessage? {
        allMessages.values.last
    }
    
    var ids: [String] {
        Array(allMessages.keys)
    }
    
    var messages: [ChatMessage] {
        Array(allMessages.values)
    }
    
    func message(id: String) -> ChatMessage? {
        allMessages[id]
    }
    
    func message(index: Int) -> ChatMessage? {
        allMessages.values[safe: index]
    }
    
    func message(orderId: String) -> ChatMessage? {
        allMessages.values.first(where: { $0.orderID == orderId })
    }
    
    mutating func cleaLast(maxCache: Int) {
        if allMessages.count > maxCache {
            allMessages.removeLast(allMessages.count - maxCache)
        }
    }
    
    mutating func cleanFirst(maxCache: Int) {
        if allMessages.count > maxCache {
            allMessages.removeFirst(allMessages.count - maxCache)
        }
    }
    
    mutating func removeAll() {
        allMessages.removeAll()
    }
    
    mutating func remove(messageId: String) -> ChatMessage? {
        allMessages.removeValue(forKey: messageId)
    }
    
    mutating func add(_ message: ChatMessage) {
        if allMessages[message.id].isNotNil {
            // We don't make assert. It's normal for cases:
            // 1. We requested a chat subscription, and it was empty.
            // 2. They requested messages via ChatGetMessage, the middle gave the messages
            // 3. The chatAdd event came with the same messages
            return
        }
        allMessages[message.id] = message
        allMessages.sort { $0.value.orderID < $1.value.orderID }
    }
    
    mutating func update(_ message: ChatMessage) {
        if allMessages[message.id].isNil {
            anytypeAssertionFailure("Object Not found for update")
            return
        }
        allMessages[message.id] = message
    }
    
    mutating func add(_ messages: [ChatMessage]) {
        for message in messages {
            allMessages[message.id] = message
        }
        allMessages.sort { $0.value.orderID < $1.value.orderID }
    }
}
