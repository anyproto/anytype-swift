import Foundation
import Factory
import AsyncTools
import AsyncAlgorithms
@preconcurrency import Combine
import AnytypeCore
import Services


protocol SpaceHubSpacesStorageProtocol: Sendable {
    var spacesStream: AnyAsyncSequence<[ParticipantSpaceViewDataWithPreview]> { get async }
}

// Chat previews are the hub's sort key and arrive late: the middleware subscribes to every chat
// in every space on login, and chats of spaces that finish loading afterwards are pushed as
// events. A space with no preview yet sorts by the message date remembered from the previous
// launch, so the hub paints in the order the user last saw and rows don't jump as previews
// trickle in. Once a space's previews have arrived they are the truth even without a message
// (deleted, archived or empty chat); otherwise a stale date would float that space forever.
actor SpaceHubSpacesStorage: SpaceHubSpacesStorageProtocol {

    struct BuildResult {
        let spaces: [ParticipantSpaceViewDataWithPreview]
        /// spaceId -> latest message date of every space whose previews have arrived; the value
        /// is nil when those previews carry no message. Spaces still loading are absent.
        let arrivedLastMessageDates: [String: Date?]
    }

    @Injected(\.participantSpacesStorage)
    private var participantSpacesStorage: any ParticipantSpacesStorageProtocol

    @Injected(\.chatMessagesPreviewsStorage)
    private var chatMessagesPreviewsStorage: any ChatMessagesPreviewsStorageProtocol

    @Injected(\.chatDetailsStorage)
    private var chatDetailsStorage: any ChatDetailsStorageProtocol

    @Injected(\.objectsWithUnreadDiscussionsSubscription)
    private var objectsWithUnreadDiscussionsSubscription: any ObjectsWithUnreadDiscussionsSubscriptionProtocol

    @Injected(\.userDefaultsStorage)
    private var userDefaults: any UserDefaultsStorageProtocol

    var spacesStream: AnyAsyncSequence<[ParticipantSpaceViewDataWithPreview]> {
        get async {
            let userDefaults = self.userDefaults
            let chatTriple = combineLatest(
                participantSpacesStorage.activeOrLoadingParticipantSpacesPublisher.values,
                await chatMessagesPreviewsStorage.previewsSequence,
                await chatDetailsStorage.allChatsSequence
            )
            let combineStream = combineLatest(
                chatTriple,
                await objectsWithUnreadDiscussionsSubscription.unreadBySpaceSequence
            ).throttle(milliseconds: 300)

            return combineStream.map { (triple, discussionUnreadBySpace) in
                let (spaces, previews, chatDetails) = triple
                // Built off the actor so the stream's subscribers don't serialize on it; only the
                // read-merge-write of the remembered dates is isolated.
                let result = Self.build(
                    spaces: spaces,
                    previews: previews,
                    chatDetails: chatDetails,
                    discussionUnreadBySpace: discussionUnreadBySpace,
                    rememberedLastMessageDates: userDefaults.spaceHubLastMessageDates
                )
                await self.remember(result.arrivedLastMessageDates)
                return result.spaces
            }
            .removeDuplicates()
            .eraseToAnyAsyncSequence()
        }
    }

    static func build(
        spaces: [ParticipantSpaceViewData],
        previews: [ChatMessagePreview],
        chatDetails: [ObjectDetails],
        discussionUnreadBySpace: [String: SpaceDiscussionsUnreadInfo],
        rememberedLastMessageDates: [String: Date]
    ) -> BuildResult {
        var arrivedLastMessageDates: [String: Date?] = [:]

        let result = spaces.map { space -> ParticipantSpaceViewDataWithPreview in
            let spaceId = space.spaceView.targetSpaceId
            let spacePreviews = previews.filter { $0.spaceId == spaceId }

            let nonArchivedPreviews = spacePreviews.filter { preview in
                guard let chatDetail = chatDetails.first(where: { $0.id == preview.chatId }) else { return false }
                return !chatDetail.isArchivedOrDeleted
            }

            let discussionUnread = discussionUnreadBySpace[spaceId]
            let counterData = SpacePreviewCountersBuilder.build(
                spaceView: space.spaceView,
                previews: nonArchivedPreviews,
                discussionUnread: discussionUnread
            )

            let latestPreview = nonArchivedPreviews.max(by: { preview1, preview2 in
                guard let date1 = preview1.lastMessage?.createdAt,
                      let date2 = preview2.lastMessage?.createdAt else {
                    return preview1.lastMessage == nil
                }
                return date1 < date2
            }) ?? ChatMessagePreview(spaceId: space.id, chatId: space.spaceView.chatId)

            let messageDate = latestPreview.lastMessage?.createdAt
            let lastMessageDate: Date?
            if spacePreviews.isNotEmpty {
                // updateValue keeps a nil date as an explicit "arrived, no message" entry.
                arrivedLastMessageDates.updateValue(messageDate, forKey: spaceId)
                lastMessageDate = messageDate
            } else {
                lastMessageDate = rememberedLastMessageDates[spaceId]
            }

            let unreadPreviews = nonArchivedPreviews
                .filter { preview in
                    guard preview.hasCounters else { return false }
                    if FeatureFlags.muteAndHide && space.spaceView.spaceType.supportsMultiChats {
                        let mode = space.spaceView.effectiveNotificationMode(for: preview.chatId)
                        if mode == .nothing {
                            return preview.mentionCounter > 0 || preview.hasUnreadReactions
                        }
                    }
                    return true
                }
                .sorted { preview1, preview2 in
                    let date1 = preview1.lastMessage?.createdAt ?? .distantPast
                    let date2 = preview2.lastMessage?.createdAt ?? .distantPast
                    return date1 > date2
                }

            let visibleDiscussionParents = filterVisibleDiscussionParents(
                discussionUnread?.parents ?? [],
                spaceView: space.spaceView
            )

            return ParticipantSpaceViewDataWithPreview(
                space: space,
                latestPreview: latestPreview,
                lastMessageDate: lastMessageDate,
                totalUnreadCounter: counterData.totalUnread,
                totalMentionCounter: counterData.totalMentions,
                hasUnreadReactions: counterData.hasUnreadReactions,
                unreadCounterStyle: counterData.unreadStyle,
                mentionCounterStyle: counterData.mentionStyle,
                reactionStyle: counterData.reactionStyle,
                unreadPreviews: unreadPreviews,
                unreadDiscussionParents: visibleDiscussionParents
            )
        }

        return BuildResult(spaces: result, arrivedLastMessageDates: arrivedLastMessageDates)
    }

    /// Stores the date of every space whose previews arrived and drops the entry when they carry
    /// no message. Spaces still loading keep their remembered date, so a partial preview set never
    /// erases the order the next launch needs.
    static func rememberedLastMessageDates(
        _ remembered: [String: Date],
        updatedWith arrivedLastMessageDates: [String: Date?]
    ) -> [String: Date] {
        var dates = remembered
        for (spaceId, date) in arrivedLastMessageDates {
            dates[spaceId] = date
        }
        return dates
    }

    static func filterVisibleDiscussionParents(
        _ parents: [DiscussionUnreadParent],
        spaceView: SpaceView
    ) -> [DiscussionUnreadParent] {
        parents.filter { parent in
            if FeatureFlags.muteAndHide && !spaceView.isOneToOne,
               spaceView.pushNotificationMode == .nothing {
                return parent.hasUnreadMention
            }
            // Aggregator admits any subscribed parent; drop fully-caught-up rows
            // so the multichat preview never shows a name with no badge.
            return parent.unreadMessageCount > 0 || parent.hasUnreadMention
        }
    }

    // MARK: - Private

    private func remember(_ arrivedLastMessageDates: [String: Date?]) {
        let remembered = userDefaults.spaceHubLastMessageDates
        let updated = Self.rememberedLastMessageDates(remembered, updatedWith: arrivedLastMessageDates)
        if updated != remembered {
            userDefaults.spaceHubLastMessageDates = updated
        }
    }
}

extension Container {
    var spaceHubSpacesStorage: Factory<any SpaceHubSpacesStorageProtocol> {
        self { SpaceHubSpacesStorage() }.shared
    }
}
