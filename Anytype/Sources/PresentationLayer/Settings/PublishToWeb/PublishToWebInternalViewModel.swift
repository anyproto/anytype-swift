import Foundation
import Combine
import SwiftUI
import Services
import AnytypeCore
import ProtobufMessages

enum DomainType: Equatable, Hashable {
    case paid(String)
    case free(String)
}

struct PublishToWebViewInternalData: Identifiable, Hashable {
    let objectId: String
    let spaceId: String
    let domain: DomainType
    let status: PublishState?
    
    var id: String { objectId + spaceId }
}

@MainActor
final class PublishToWebInternalViewModel: ObservableObject {
    
    @Published var customPath: String = ""
    @Published var showJoinSpaceButton: Bool = true
    @Published var canPublish: Bool = true
    @Published var status: PublishState?
    
    @Published var error: String?
    
    @Published var showMembership = false
    
    let domain: DomainType
    
    @Injected(\.publishingService)
    private var publishingService: any PublishingServiceProtocol
    
    private let spaceId: String
    private let objectId: String
    
    init(data: PublishToWebViewInternalData) {
        spaceId = data.spaceId
        objectId = data.objectId
        domain = data.domain
        status = data.status
        
        customPath = data.status?.uri ?? ""
        showJoinSpaceButton = data.status?.joinSpace ?? true
        
        setupBindings()
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
        showMembership.toggle()
    }
    
    private func setupBindings() {
        $customPath
            .map { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .assign(to: &$canPublish)
    }
}
