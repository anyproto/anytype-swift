import Services

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
        previews: [ChatMessagePreview]
    ) -> SpacePreviewCountersData {
        let counters = aggregateCounters(spaceView: spaceView, previews: previews)
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
        let totalUnread: Int
        let totalMentions: Int
        let hasUnreadReactions: Bool
        let hasHighlightedUnread: Bool
        let hasHighlightedMention: Bool
        let hasHighlightedReaction: Bool
    }

    private static func aggregateCounters(
        spaceView: SpaceView,
        previews: [ChatMessagePreview]
    ) -> AggregatedCounters {
        var totalUnread = 0
        var totalMentions = 0
        var hasUnreadReactions = false
        var hasHighlightedUnread = false
        var hasHighlightedMention = false
        var hasHighlightedReaction = false

        for preview in previews {
            let effectiveMode = spaceView.effectiveNotificationMode(for: preview.chatId)

            totalUnread += preview.unreadCounter
            // TODO: IOS-5561 - Temporary client-side fix. Should be handled by middleware.
            if spaceView.uxType.supportsMentions {
                totalMentions += preview.mentionCounter
            }

            if preview.unreadCounter > 0 && effectiveMode == .all {
                hasHighlightedUnread = true
            }
            if preview.mentionCounter > 0 && (effectiveMode == .all || effectiveMode == .mentions) {
                hasHighlightedMention = true
            }
            if preview.hasUnreadReactions {
                hasUnreadReactions = true
                if effectiveMode == .all || effectiveMode == .mentions {
                    hasHighlightedReaction = true
                }
            }
        }

        return AggregatedCounters(
            totalUnread: totalUnread,
            totalMentions: totalMentions,
            hasUnreadReactions: hasUnreadReactions,
            hasHighlightedUnread: hasHighlightedUnread,
            hasHighlightedMention: hasHighlightedMention,
            hasHighlightedReaction: hasHighlightedReaction
        )
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
            return (unread: .muted, mention: .highlighted, reaction: .highlighted)
        case .nothing, .UNRECOGNIZED:
            return (unread: .muted, mention: .muted, reaction: .muted)
        }
    }
}
