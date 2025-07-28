import Foundation
import SwiftUI
import Services
import AnytypeCore
import ProtobufMessages


@MainActor
final class PublishToWebInternalViewModel: ObservableObject {
    
    @Published var customPath: String = ""
    @Published var showJoinSpaceButton: Bool = true
    @Published var status: PublishState?
    
    @Published var error: String?
    @Published var previewData: PublishingPreviewData = .empty
    
    let domain: DomainType
    
    private weak var output: (any PublishToWebModuleOutput)?
    
    @Injected(\.publishingService)
    private var publishingService: any PublishingServiceProtocol
    @Injected(\.publishingPreviewBuilder)
    private var previewBuilder: any PublishingPreviewBuilderProtocol
    
    private let spaceId: String
    private let objectId: String
    
    init(data: PublishToWebViewInternalData, output: (any PublishToWebModuleOutput)?) {
        spaceId = data.spaceId
        objectId = data.objectId
        domain = data.domain
        status = data.status
        self.output = output
        
        customPath = data.status?.uri ?? ""
        showJoinSpaceButton = data.status?.joinSpace ?? true
        
        previewData = previewBuilder.buildPreviewData(
            from: data.objectDetails,
            spaceName: data.spaceName,
            showJoinButton: showJoinSpaceButton
        )
    }
    
    func onPublishTap() async throws {
        try await publishingService.create(spaceId: spaceId, objectId: objectId, uri: customPath, joinSpace: showJoinSpaceButton)
        status = try await publishingService.getStatus(spaceId: spaceId, objectId: objectId)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    
    func onUnpublishTap() async throws {
        try await publishingService.remove(spaceId: spaceId, objectId: objectId)
        status = try await publishingService.getStatus(spaceId: spaceId, objectId: objectId)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    
    func onFreeDomainTap() {
        output?.onShowMembership()
    }
    
    func updatePreviewForJoinButton(_ showJoin: Bool) {
        previewData = previewBuilder.buildPreviewData(
            from: previewData,
            showJoinButton: showJoin
        )
    }
    
    }
}
