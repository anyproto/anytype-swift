import Foundation
import Factory
import Services
import AnytypeCore

protocol ChatMessageLimitsProtocol: AnyObject, Sendable {
    var textLimit: Int { get }
    var attachmentsLimit: Int { get }
    func textIsLimited(text: NSAttributedString) -> Bool
    func textIsWarinig(text: NSAttributedString) -> Bool
    func canAddReaction(message: ChatMessage, yourProfileIdentity: String) -> Bool
    func canSendMessage() -> Bool
    func markSentMessage()
    func countAttachmentsCanBeAdded(current: Int) -> Int
    func oneAttachmentCanBeAdded(current: Int) -> Bool
}

enum ChatMessageGlobalLimits {
    static let textLimit = 2000
    static let textLimitWarning = 1950
}

final class ChatMessageLimits: ChatMessageLimitsProtocol, Sendable {
    
    private struct MessageLimitStorage {
        var firstMessageSentDate = Date(timeIntervalSince1970: 0)
        var countMessagesSent: Int = 0
    }
    
    private enum Constants {
        static let reactionsForMemberLimit = 3
        static let reactionsForMessageLimit = 12
        static let sendMessagesCountLimit = 5
        static let sendMessagesTimeLimitSec: TimeInterval = 5
        static let attachmentsLimit: Int = 10
    }
    
    private let messageLimitStorage = AtomicStorage(MessageLimitStorage())
    
    var textLimit: Int {
        ChatMessageGlobalLimits.textLimit
    }
    
    var attachmentsLimit: Int {
        Constants.attachmentsLimit
    }
    
    func textIsLimited(text: NSAttributedString) -> Bool {
        text.string.count > ChatMessageGlobalLimits.textLimit
    }
    
    func textIsWarinig(text: NSAttributedString) -> Bool {
        text.string.count >= ChatMessageGlobalLimits.textLimitWarning
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
    
    func countAttachmentsCanBeAdded(current: Int) -> Int {
        return Constants.attachmentsLimit - current
    }
    
    func oneAttachmentCanBeAdded(current: Int) -> Bool {
        return Constants.attachmentsLimit - current > 0
    }
}

extension Container {
    var chatMessageLimits: Factory<any ChatMessageLimitsProtocol> {
        self { ChatMessageLimits() }
    }
}
