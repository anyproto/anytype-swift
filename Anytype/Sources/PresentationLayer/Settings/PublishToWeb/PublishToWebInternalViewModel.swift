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
        
        setupBindings()
    }
    
    func onPublishTap() {
        // TBD;
    }
    
    func onUnpublishTap() {
        // TBD;
    }
    
    private func setupBindings() {
        $customPath
            .map { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .assign(to: &$canPublish)
    }
}
