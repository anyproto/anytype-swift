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

    var spacesStream: AnyAsyncSequence<[ParticipantSpaceViewDataWithPreview]> {
        get async {
            let combineStream = combineLatest(
                participantSpacesStorage.activeOrLoadingParticipantSpacesPublisher.values,
                await chatMessagesPreviewsStorage.previewsSequence,
                await chatDetailsStorage.allChatsSequence
            ).throttle(milliseconds: 300)

            return combineStream.map { (spaces, previews, chatDetails) in
                spaces.map { space in
                    let spacePreviews = previews.filter { $0.spaceId == space.spaceView.targetSpaceId }

                    let nonArchivedPreviews = spacePreviews.filter { preview in
                        guard let chatDetail = chatDetails.first(where: { $0.id == preview.chatId }) else { return false }
                        return !chatDetail.isArchivedOrDeleted
                    }

                    guard let latestPreview = nonArchivedPreviews.max(by: { preview1, preview2 in
                        guard let date1 = preview1.lastMessage?.createdAt,
                              let date2 = preview2.lastMessage?.createdAt else {
                            return preview1.lastMessage == nil
                        }
                        return date1 < date2
                    }) else {
                        return ParticipantSpaceViewDataWithPreview(space: space)
                    }

                    let counterData = SpacePreviewCountersBuilder.build(
                        spaceView: space.spaceView,
                        previews: nonArchivedPreviews
                    )

                    let unreadPreviews = nonArchivedPreviews
                        .filter { preview in
                            guard preview.hasCounters else { return false }
                            if FeatureFlags.muteAndHide {
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

                    return ParticipantSpaceViewDataWithPreview(
                        space: space,
                        latestPreview: latestPreview,
                        totalUnreadCounter: counterData.totalUnread,
                        totalMentionCounter: counterData.totalMentions,
                        hasUnreadReactions: counterData.hasUnreadReactions,
                        unreadCounterStyle: counterData.unreadStyle,
                        mentionCounterStyle: counterData.mentionStyle,
                        reactionStyle: counterData.reactionStyle,
                        unreadPreviews: unreadPreviews
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
