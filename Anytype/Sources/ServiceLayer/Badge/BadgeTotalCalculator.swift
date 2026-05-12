import Foundation
import Services

enum BadgeTotalCalculator {

    static func compute(
        previews: [ChatMessagePreview],
        spaceViews: [SpaceView],
        chatDetails: [ObjectDetails],
        discussionsBySpace: [String: SpaceDiscussionsUnreadInfo]
    ) -> Int {
        let spaceViewById = Dictionary(spaceViews.map { ($0.targetSpaceId, $0) }, uniquingKeysWith: { _, last in last })
        var total = 0

        for preview in previews {
            guard let chatDetail = chatDetails.first(where: { $0.id == preview.chatId }),
                  !chatDetail.isArchivedOrDeleted else {
                continue
            }
            guard let spaceView = spaceViewById[preview.spaceId], spaceView.isActive else { continue }

            switch spaceView.effectiveNotificationMode(for: preview.chatId) {
            case .all:
                total += preview.unreadCounter
            case .mentions:
                if spaceView.uxType.supportsMentions {
                    total += preview.mentionCounter
                }
            case .nothing, .UNRECOGNIZED:
                break
            }
        }

        for (spaceId, info) in discussionsBySpace {
            guard let spaceView = spaceViewById[spaceId], spaceView.isActive else { continue }

            switch spaceView.pushNotificationMode {
            case .all:
                // Subscribed-parent messages already include their mentions; add unsubscribed-parent
                // mentions on top so a mention in an object I don't watch still bumps the badge.
                total += info.unreadMessageCount + info.unsubscribedMentionCount
            case .mentions:
                if spaceView.uxType.supportsMentions {
                    total += info.totalMentionCount
                }
            case .nothing, .UNRECOGNIZED:
                break
            }
        }

        return total
    }
}
