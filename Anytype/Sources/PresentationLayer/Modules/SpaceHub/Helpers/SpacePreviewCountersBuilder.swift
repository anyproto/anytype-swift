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
        let totalUnread: Int
        let totalMentions: Int
        let hasUnreadReactions: Bool
        let hasHighlightedUnread: Bool
        let hasHighlightedMention: Bool
        let hasHighlightedReaction: Bool
    }

    private static func aggregateCounters(
        spaceView: SpaceView,
        previews: [ChatMessagePreview],
        discussionUnread: SpaceDiscussionsUnreadInfo?
    ) -> AggregatedCounters {
        var totalUnread = 0
        var totalMentions = 0
        var hasUnreadReactions = false
        var hasHighlightedUnread = false
        var hasHighlightedMention = false
        var hasHighlightedReaction = false

        let supportsMentions = !spaceView.isOneToOne

        for preview in previews {
            let effectiveMode = spaceView.effectiveNotificationMode(for: preview.chatId)

            if FeatureFlags.muteAndHide && !spaceView.isOneToOne {
                switch effectiveMode {
                case .all, .mentions, .UNRECOGNIZED:
                    totalUnread += preview.unreadCounter
                    // TODO: IOS-5561 - Temporary client-side fix. Should be handled by middleware.
                    if supportsMentions {
                        totalMentions += preview.mentionCounter
                    }
                case .nothing:
                    if supportsMentions {
                        totalMentions += preview.mentionCounter
                    }
                }
            } else {
                totalUnread += preview.unreadCounter
                // TODO: IOS-5561 - Temporary client-side fix. Should be handled by middleware.
                if supportsMentions {
                    totalMentions += preview.mentionCounter
                }
            }

            if preview.unreadCounter > 0 && effectiveMode == .all {
                hasHighlightedUnread = true
            }
            if preview.mentionCounter > 0 && (effectiveMode == .all || effectiveMode == .mentions) {
                hasHighlightedMention = true
            }
            if preview.hasUnreadReactions {
                hasUnreadReactions = true
                if effectiveMode == .all {
                    hasHighlightedReaction = true
                }
            }
        }

        if let discussionUnread {
            let mode = spaceView.pushNotificationMode

            if FeatureFlags.muteAndHide && !spaceView.isOneToOne {
                switch mode {
                case .all, .mentions, .UNRECOGNIZED:
                    totalUnread += discussionUnread.unreadMessageCount
                    if supportsMentions {
                        totalMentions += discussionUnread.unreadMentionCount
                    }
                case .nothing:
                    if supportsMentions {
                        totalMentions += discussionUnread.unreadMentionCount
                    }
                }
            } else {
                totalUnread += discussionUnread.unreadMessageCount
                if supportsMentions {
                    totalMentions += discussionUnread.unreadMentionCount
                }
            }

            if discussionUnread.unreadMessageCount > 0 && mode == .all {
                hasHighlightedUnread = true
            }
            if discussionUnread.unreadMentionCount > 0 && (mode == .all || mode == .mentions) {
                hasHighlightedMention = true
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
            return (unread: .muted, mention: .highlighted, reaction: .muted)
        case .nothing, .UNRECOGNIZED:
            return (unread: .muted, mention: .muted, reaction: .muted)
        }
    }
}
