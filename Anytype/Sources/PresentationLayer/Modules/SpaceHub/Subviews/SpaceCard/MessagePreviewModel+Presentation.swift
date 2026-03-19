import SwiftUI

extension MessagePreviewModel {

    var isMuted: Bool {
        !notificationMode.isUnmutedAll
    }

    var unreadCounterStyle: CounterViewStyle {
        notificationMode.unreadCounterStyle
    }

    var mentionCounterStyle: MentionBadgeStyle {
        notificationMode.mentionCounterStyle
    }

    var messagePreviewText: String {
        if let authorName = creatorTitle, authorName.isNotEmpty {
            return "\(authorName): \(localizedAttachmentsText)"
        }
        return localizedAttachmentsText
    }

    var titleColor: Color {
        if !isMuted {
            .Text.primary
        } else {
            .Text.secondary
        }
    }

    var messagePreviewColor: Color {
        guard !isMuted else { return .Text.secondary }
        return totalCounter > 0 ? .Text.primary : .Text.secondary
    }

    var totalCounter: Int {
        unreadCounter + mentionCounter
    }

    var hasCounters: Bool {
        totalCounter > 0
    }
}
