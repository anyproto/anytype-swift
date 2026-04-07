import Foundation
import Factory
import Services
import AnytypeCore

enum DiscussionMessageGlobalLimits {
    static let textLimit = 8000
    static let textLimitWarning = 7950
}

final class DiscussionMessageLimits: ChatMessageLimitsProtocol, Sendable {

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
    private let currentDateProvider: any ChatMessageLimitsDateProviderProtocol = Container.shared.chatDateProvider()

    var textLimit: Int {
        DiscussionMessageGlobalLimits.textLimit
    }

    var attachmentsLimit: Int {
        Constants.attachmentsLimit
    }

    func textIsLimited(text: NSAttributedString) -> Bool {
        text.string.count > DiscussionMessageGlobalLimits.textLimit
    }

    func textIsWarinig(text: NSAttributedString) -> Bool {
        text.string.count >= DiscussionMessageGlobalLimits.textLimitWarning
    }

    func canAddReaction(message: ChatMessage, yourProfileIdentity: String) -> Bool {
        let yourReactions = message.reactions.reactions.filter { $1.ids.contains(yourProfileIdentity) }.count
        let canAddReaction = message.reactions.reactions.count < Constants.reactionsForMessageLimit
            && yourReactions < Constants.reactionsForMemberLimit
        return canAddReaction
    }

    func canSendMessage() -> Bool {
        messageLimitStorage.access { value in
            if value.firstMessageSentDate.distance(to: currentDateProvider.currentDate()) > Constants.sendMessagesTimeLimitSec {
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
            if value.firstMessageSentDate.distance(to: currentDateProvider.currentDate()) > Constants.sendMessagesTimeLimitSec {
                value.countMessagesSent = 1
                value.firstMessageSentDate = currentDateProvider.currentDate()
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
    var discussionMessageLimits: Factory<any ChatMessageLimitsProtocol> {
        self { DiscussionMessageLimits() }
    }
}
