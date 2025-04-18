import Foundation
import Factory
import AsyncTools
import AsyncAlgorithms
@preconcurrency import Combine
import AnytypeCore

protocol SpaceHubSpacesStorageProtocol: Sendable {
    var spacesStream: AnyAsyncSequence<[ParticipantSpaceViewData]> { get async }
}

actor SpaceHubSpacesStorage: SpaceHubSpacesStorageProtocol {
    
    @Injected(\.participantSpacesStorage)
    private var participantSpacesStorage: any ParticipantSpacesStorageProtocol
    
    @Injected(\.chatMessagesPreviewsStorage)
    private var chatMessagesPreviewsStorage: any ChatMessagesPreviewsStorageProtocol
    
    var spacesStream: AnyAsyncSequence<[ParticipantSpaceViewData]> {
        get async {
            if FeatureFlags.countersOnSpaceHub {
                
                Task {
                    await chatMessagesPreviewsStorage.startSubscriptionIfNeeded()
                }
                
                let combineStream = combineLatest(
                    participantSpacesStorage.activeOrLoadingParticipantSpacesPublisher.values,
                    chain([[ChatMessagePreview]()].async, await chatMessagesPreviewsStorage.previewsSequence)
                )._throttle(for: .milliseconds(300))
                
                return combineStream.map { (spaces, previews) in
                    var spaces = spaces
                    
                    for preview in previews {
                        if let spaceIndex = spaces.firstIndex(where: { $0.spaceView.targetSpaceId == preview.spaceId }) {
                            spaces[spaceIndex] = spaces[spaceIndex].updateUnreadMessagesCount(preview.counter)
                        }
                    }
                    
                    return spaces
                }.eraseToAnyAsyncSequence()
            } else {
                return participantSpacesStorage.activeOrLoadingParticipantSpacesPublisher.values
                    ._throttle(for: .milliseconds(300))
                    .eraseToAnyAsyncSequence()
            }
        }
    }
}

extension Container {
    var spaceHubSpacesStorage: Factory<any SpaceHubSpacesStorageProtocol> {
        self { SpaceHubSpacesStorage() }.shared
    }
}
