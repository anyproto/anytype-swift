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
            if FeatureFlags.countersOnSpaceHub {
                
                let combineStream = combineLatest(
                    participantSpacesStorage.activeOrLoadingParticipantSpacesPublisher.values,
                     await chatMessagesPreviewsStorage.previewsSequenceWithEmpty
                ).throttle(milliseconds: 300)
                
                return combineStream.map { (spaces, previews) in
                    var spaces = spaces.map { ParticipantSpaceViewDataWithPreview(space: $0) }
                    
                    for preview in previews {
                        if let spaceIndex = spaces.firstIndex(where: { $0.spaceView.targetSpaceId == preview.spaceId }) {
                            let participantSpace = spaces[spaceIndex]
                            
                            // Needs to understand how this logic should be work if user delete chat widget. For feature release
                            let showUnread = FeatureFlags.chatWidget || participantSpace.spaceView.initialScreenIsChat
                            
                            if showUnread, participantSpace.spaceView.chatId == preview.chatId {
                                spaces[spaceIndex] = spaces[spaceIndex].updated(preview: preview)
                            }
                        }
                    }
                    
                    return spaces
                }
                .removeDuplicates()
                .eraseToAnyAsyncSequence()
            } else {
                return participantSpacesStorage.activeOrLoadingParticipantSpacesPublisher.values
                    .throttle(milliseconds: 300)
                    .map { $0.map { ParticipantSpaceViewDataWithPreview(space: $0) } }
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
