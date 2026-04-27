import Foundation
import Factory
import AsyncTools
import AsyncAlgorithms
@preconcurrency import Combine
import AnytypeCore


protocol SpaceHubSpacesStorageProtocol: Sendable {
    var spacesStream: AnyAsyncSequence<[ParticipantSpaceViewDataWithPreview]> { get async }
}

actor SpaceHubSpacesStorage: SpaceHubSpacesStorageProtocol {

    @Injected(\.participantSpacesStorage)
    private var participantSpacesStorage: any ParticipantSpacesStorageProtocol

    @Injected(\.chatMessagesPreviewsStorage)
    private var chatMessagesPreviewsStorage: any ChatMessagesPreviewsStorageProtocol

    @Injected(\.chatDetailsStorage)
    private var chatDetailsStorage: any ChatDetailsStorageProtocol

    @Injected(\.objectsWithUnreadDiscussionsSubscription)
    private var objectsWithUnreadDiscussionsSubscription: any ObjectsWithUnreadDiscussionsSubscriptionProtocol

    var spacesStream: AnyAsyncSequence<[ParticipantSpaceViewDataWithPreview]> {
        get async {
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
                return spaces.map { space in
                    let spacePreviews = previews.filter { $0.spaceId == space.spaceView.targetSpaceId }

                    let nonArchivedPreviews = spacePreviews.filter { preview in
                        guard let chatDetail = chatDetails.first(where: { $0.id == preview.chatId }) else { return false }
                        return !chatDetail.isArchivedOrDeleted
                    }

                    let discussionUnread = discussionUnreadBySpace[space.spaceView.targetSpaceId]
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

                    let unreadPreviews = nonArchivedPreviews
                        .filter { preview in
                            guard preview.hasCounters else { return false }
                            if FeatureFlags.muteAndHide && space.spaceView.uxType.supportsMultiChats {
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

                    let visibleDiscussionParents = (discussionUnread?.parents ?? []).filter { parent in
                        if FeatureFlags.muteAndHide && space.spaceView.uxType.supportsMultiChats,
                           space.spaceView.pushNotificationMode == .nothing {
                            return parent.hasUnreadMention
                        }
                        return true
                    }

                    return ParticipantSpaceViewDataWithPreview(
                        space: space,
                        latestPreview: latestPreview,
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
            }
            .removeDuplicates()
            .eraseToAnyAsyncSequence()
        }
    }
}

extension Container {
    var spaceHubSpacesStorage: Factory<any SpaceHubSpacesStorageProtocol> {
        self { SpaceHubSpacesStorage() }.shared
    }
}
