import Foundation
import AnytypeCore

protocol ChatMessagesStorageProviderProtocol: AnyObject {
    func chatStorage(chatObjectId: String) -> any ChatMessagesStorageProtocol
}

final class ChatMessagesStorageProvider: ChatMessagesStorageProviderProtocol {
    
    private let lock = NSLock()
    private var cache = [String: Weak<ChatMessagesStorage>]()
    
    // MARK: - ChatMessagesStorageProviderProtocol
    
    func chatStorage(chatObjectId: String) -> any ChatMessagesStorageProtocol {
        
        lock.lock()
        defer { lock.unlock() }
        
        if let storage = cache[chatObjectId]?.value {
            return storage
        }
        
        let storage = ChatMessagesStorage(chatObjectId: chatObjectId)
        cache[chatObjectId] = Weak(value: storage)
        return storage
    }
}
