import Services
import ProtobufMessages
import AnytypeCore

// Events Handling

extension ChatInternalMessageStorage {
    
    @discardableResult
    mutating func chatAdd(_ data: Anytype_Event.Chat.Add) -> Bool {
        if messages.isEmpty {
            add(data.message)
            return true
        }
        
        if let firstMessage = first,
            let lastMessage = last,
           firstMessage.orderID <= data.afterOrderID,
            lastMessage.orderID >= data.afterOrderID {
            add(data.message)
            return true
        }
        
        return false
    }
    
    @discardableResult
    mutating func chatDelete(_ data: Anytype_Event.Chat.Delete) -> Bool {
        remove(messageId: data.id).isNotNil
    }
    
    @discardableResult
    mutating func chatUpdate(_ data: Anytype_Event.Chat.Update) -> Bool {
        if message(id: data.message.id).isNotNil {
            update(data.message)
            return true
        }
        return false
    }
    
    @discardableResult
    mutating func chatUpdateReactions(_ data: Anytype_Event.Chat.UpdateReactions) -> Bool {
        if var message = message(id: data.id) {
            message.reactions = data.reactions
            update(message)
            return true
        }
        return false
    }
    
    @discardableResult
    mutating func chatUpdateReadStatus(_ data: Anytype_Event.Chat.UpdateReadStatus) -> Bool {
        var updated = false
        for messageId in data.ids {
            if var message = message(id: messageId) {
                message.read = data.isRead
                update(message)
                updated = true
            }
        }
        return updated
    }
}
