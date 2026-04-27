import Services
import AnytypeCore

struct SpacePreviewCountersData: Equatable {
    let totalUnread: Int
    let totalMentions: Int
    let hasUnreadReactions: Bool
    let unreadStyle: CounterViewStyle
    let mentionStyle: BadgeStyle
    let reactionStyle: BadgeStyle
}

enum SpacePreviewCountersBuilder {

    static func build(
        spaceView: SpaceView,
        previews: [ChatMessagePreview],
        discussionUnread: SpaceDiscussionsUnreadInfo?
    ) -> SpacePreviewCountersData {
        let counters = aggregateCounters(
            spaceView: spaceView,
            previews: previews,
            discussionUnread: discussionUnread
        )
        let styles = determineStyles(spaceView: spaceView, counters: counters)

        return SpacePreviewCountersData(
            totalUnread: counters.totalUnread,
            totalMentions: counters.totalMentions,
            hasUnreadReactions: counters.hasUnreadReactions,
            unreadStyle: styles.unread,
            mentionStyle: styles.mention,
            reactionStyle: styles.reaction
        )
    }

    // MARK: - Aggregation

    private struct AggregatedCounters {
        var totalUnread = 0
        var totalMentions = 0
        var hasUnreadReactions = false
        var hasHighlightedUnread = false
        var hasHighlightedMention = false
        var hasHighlightedReaction = false
    }

    private static func aggregateCounters(
        spaceView: SpaceView,
        previews: [ChatMessagePreview],
        discussionUnread: SpaceDiscussionsUnreadInfo?
    ) -> AggregatedCounters {
        var counters = AggregatedCounters()
        let supportsMentions = !spaceView.isOneToOne

        for preview in previews {
            let mode = spaceView.effectiveNotificationMode(for: preview.chatId)
            counters = contribute(
                unreadCount: preview.unreadCounter,
                mentionCount: preview.mentionCounter,
                mode: mode,
                spaceView: spaceView,
                supportsMentions: supportsMentions,
                counters: counters
            )
            if preview.hasUnreadReactions {
                counters.hasUnreadReactions = true
                if mode == .all {
                    counters.hasHighlightedReaction = true
                }
            }
        }

        if let discussionUnread {
            counters = contribute(
                unreadCount: discussionUnread.unreadMessageCount,
                mentionCount: discussionUnread.totalMentionCount,
                mode: spaceView.pushNotificationMode,
                spaceView: spaceView,
                supportsMentions: supportsMentions,
                counters: counters
            )
        }

        return counters
    }

    private static func contribute(
        unreadCount: Int,
        mentionCount: Int,
        mode: SpacePushNotificationsMode,
        spaceView: SpaceView,
        supportsMentions: Bool,
        counters: AggregatedCounters
    ) -> AggregatedCounters {
        var counters = counters
        let hideUnread = FeatureFlags.muteAndHide && !spaceView.isOneToOne && mode == .nothing
        if !hideUnread {
            counters.totalUnread += unreadCount
        }
        // TODO: IOS-5561 - Temporary client-side fix. Should be handled by middleware.
        if supportsMentions {
            counters.totalMentions += mentionCount
        }
        if unreadCount > 0 && mode == .all {
            counters.hasHighlightedUnread = true
        }
        if mentionCount > 0 && (mode == .all || mode == .mentions) {
            counters.hasHighlightedMention = true
        }
        return counters
    }

    // MARK: - Style Determination

    private static func determineStyles(
        spaceView: SpaceView,
        counters: AggregatedCounters
    ) -> (unread: CounterViewStyle, mention: BadgeStyle, reaction: BadgeStyle) {
        let hasCustomOverrides = spaceView.forceAllIds.isNotEmpty ||
                                 spaceView.forceMuteIds.isNotEmpty ||
                                 spaceView.forceMentionIds.isNotEmpty

        if hasCustomOverrides {
            return (
                unread: counters.hasHighlightedUnread ? .highlighted : .muted,
                mention: counters.hasHighlightedMention ? .highlighted : .muted,
                reaction: counters.hasHighlightedReaction ? .highlighted : .muted
            )
        }

        switch spaceView.pushNotificationMode {
        case .all:
            return (unread: .highlighted, mention: .highlighted, reaction: .highlighted)
        case .mentions:
            return (unread: .muted, mention: .highlighted, reaction: .muted)
        case .nothing, .UNRECOGNIZED:
            return (unread: .muted, mention: .muted, reaction: .muted)
        }
    }
}
