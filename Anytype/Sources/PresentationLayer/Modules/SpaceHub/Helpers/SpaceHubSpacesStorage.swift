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
    
    var spacesStream: AnyAsyncSequence<[ParticipantSpaceViewDataWithPreview]> {
        get async {
            let combineStream = combineLatest(
                participantSpacesStorage.activeOrLoadingParticipantSpacesPublisher.values,
                 await chatMessagesPreviewsStorage.previewsSequenceWithEmpty
            ).throttle(milliseconds: 300)
            
            return combineStream.map { (spaces, previews) in
                spaces.map { space in
                    let spacePreviews = previews.filter { $0.spaceId == space.spaceView.targetSpaceId }

                    guard let latestPreview = spacePreviews.max(by: { preview1, preview2 in
                        guard let date1 = preview1.lastMessage?.createdAt,
                              let date2 = preview2.lastMessage?.createdAt else {
                            return preview1.lastMessage == nil
                        }
                        return date1 < date2
                    }) else {
                        return ParticipantSpaceViewDataWithPreview(space: space)
                    }

                    let totalUnread = spacePreviews.reduce(0) { $0 + $1.unreadCounter }
                    // TODO: IOS-5561 - Temporary client-side fix. Should be handled by middleware.
                    let totalMentions = space.spaceView.uxType.isOneToOne
                        ? 0
                        : spacePreviews.reduce(0) { $0 + $1.mentionCounter }

                    return ParticipantSpaceViewDataWithPreview(
                        space: space,
                        latestPreview: latestPreview,
                        totalUnreadCounter: totalUnread,
                        totalMentionCounter: totalMentions
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
