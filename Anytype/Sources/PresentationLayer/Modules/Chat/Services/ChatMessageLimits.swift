import Foundation
import Factory
import Services

protocol ChatMessageLimitsProtocol: AnyObject {
    var textLimit: Int { get }
    func textIsLimited(text: NSAttributedString) -> Bool
    func textIsWarinig(text: NSAttributedString) -> Bool
    func canAddReaction(message: ChatMessage, yourProfileIdentity: String) -> Bool
}

final class ChatMessageLimits: ChatMessageLimitsProtocol {
    
    private enum Constants {
        static let textLimit = 2000
        static let textLimitWarning = 1950
        static let reactionsForMemberLimit = 3
        static let reactionsForMessageLimit = 12
    }
    
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
}

extension Container {
    var chatMessageLimits: Factory<any ChatMessageLimitsProtocol> {
        self { ChatMessageLimits() }
    }
}
