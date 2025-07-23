import Foundation
import Combine
import SwiftUI
import Services
import AnytypeCore
import ProtobufMessages

struct PublishToWebViewInternalData: Identifiable, Hashable {
    let objectId: String
    let spaceId: String
    let domain: String
    let status: PublishState?
    
    var id: Int { hashValue }
}

@MainActor
final class PublishToWebInternalViewModel: ObservableObject {
    
    @Published var customPath: String = ""
    @Published var showJoinSpaceButton: Bool = true
    @Published var canPublish: Bool = true
    @Published var status: PublishState?
    
    @Published var error: String?
    
    let domain: String
    
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
