import Foundation
import SwiftUI
import Services
import AnytypeCore
import ProtobufMessages

enum PublishToWebViewModelState: Equatable {
    case initial
    case error(String)
    case loaded(PublishToWebViewInternalData)
}

@MainActor
@Observable
final class PublishToWebViewModel {
    var state = PublishToWebViewModelState.initial

    @ObservationIgnored
    @Injected(\.publishingService)
    private var publishingService: any PublishingServiceProtocol
    @ObservationIgnored
    @Injected(\.participantsStorage)
    private var participantStorage: any ParticipantsStorageProtocol
    @ObservationIgnored
    @Injected(\.documentsProvider)
    private var documentsProvider: any DocumentsProviderProtocol
    @ObservationIgnored
    @Injected(\.spaceViewsStorage)
    private var activeWorkspaceStorage: any SpaceViewsStorageProtocol

    private let spaceId: String
    private let objectId: String
    
    init(data: PublishToWebViewData) {
        spaceId = data.spaceId
        objectId = data.objectId
    }
    
    func onAppear() async {
        guard let domain = participantStorage.participants.first?.publishingDomain else {
            anytypeAssertionFailure("No participants found for account")
            state = .error(Loc.Publishing.Error.noDomain)
            return
        }
        
        let document = documentsProvider.document(objectId: objectId, spaceId: spaceId)
        
        // Open the document to ensure data exists
        try? await document.open()
        
        guard let objectDetails = document.details else {
            anytypeAssertionFailure("No details found object")
            state = .error(Loc.Publishing.Error.noObjectData)
            return
        }
        
        let spaceView = activeWorkspaceStorage.spaceView(spaceId: spaceId)
        let spaceName = spaceView?.title ?? ""
        let spaceUxType = spaceView?.uxType ?? .data

        do {
            let status: PublishState?
            if let newStatus = try await publishingService.getStatus(spaceId: spaceId, objectId: objectId) {
                status = newStatus
            } else {
                status = nil
            }
            
            state = .loaded(PublishToWebViewInternalData(
                objectId: objectId,
                spaceId: spaceId,
                domain: domain,
                status: status,
                objectDetails: objectDetails,
                spaceName: spaceName,
                spaceUxType: spaceUxType
            ))
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
