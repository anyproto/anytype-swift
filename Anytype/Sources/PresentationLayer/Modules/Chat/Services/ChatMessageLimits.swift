import Foundation
import Factory
import Services
import AnytypeCore

protocol ChatMessageLimitsProtocol: AnyObject {
    var textLimit: Int { get }
    func textIsLimited(text: NSAttributedString) -> Bool
    func textIsWarinig(text: NSAttributedString) -> Bool
    func canAddReaction(message: ChatMessage, yourProfileIdentity: String) -> Bool
    func canSendMessage() -> Bool
    func markSentMessage()
}

final class ChatMessageLimits: ChatMessageLimitsProtocol, Sendable {
    
    private struct MessageLimitStorage {
        var firstMessageSentDate = Date(timeIntervalSince1970: 0)
        var countMessagesSent: Int = 0
    }
    
    private enum Constants {
        static let textLimit = 2000
        static let textLimitWarning = 1950
        static let reactionsForMemberLimit = 3
        static let reactionsForMessageLimit = 12
        static let sendMessagesCountLimit = 5
        static let sendMessagesTimeLimitSec: TimeInterval = 5
    }
    
    private let messageLimitStorage = AtomicStorage(MessageLimitStorage())
    
    var textLimit: Int {
        Constants.textLimit
    }
    
    func textIsLimited(text: NSAttributedString) -> Bool {
        text.string.count > Constants.textLimit
    }
    
    func textIsWarinig(text: NSAttributedString) -> Bool {
        text.string.count >= Constants.textLimitWarning
    }
    
    func canAddReaction(message: ChatMessage, yourProfileIdentity: String) -> Bool {
        let yourReactions = message.reactions.reactions.filter { $1.ids.contains(yourProfileIdentity) }.count
        let canAddReaction = message.reactions.reactions.count < Constants.reactionsForMessageLimit
            && yourReactions < Constants.reactionsForMemberLimit
        return canAddReaction
    }
    
    func canSendMessage() -> Bool {
        messageLimitStorage.access { value in
            if value.firstMessageSentDate.distance(to: Date()) > Constants.sendMessagesTimeLimitSec {
                return true
            }
            
            if value.countMessagesSent < Constants.sendMessagesCountLimit {
                return true
            }
            
            return false
        }
    }
    
    func markSentMessage() {
        messageLimitStorage.access { value in
            if value.firstMessageSentDate.distance(to: Date()) > Constants.sendMessagesTimeLimitSec {
                value.countMessagesSent = 1
                value.firstMessageSentDate = Date()
            } else {
                value.countMessagesSent += 1
            }
        }
    }
}

extension Container {
    var chatMessageLimits: Factory<any ChatMessageLimitsProtocol> {
        self { ChatMessageLimits() }
    }
}
