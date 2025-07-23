import Foundation
import Combine
import SwiftUI
import Services
import AnytypeCore

enum PublishToWebViewModelState {
    case error(String)
    case ok
    
    var isError: Bool {
       if case .error = self { return true }
       return false
   }
}

@MainActor
final class PublishToWebViewModel: ObservableObject {
    
    @Published var customPath: String = ""
    @Published var showJoinSpaceButton: Bool = true
    @Published var canPublish: Bool = true
    
    @Published var state = PublishToWebViewModelState.ok
    
    let domain: String
    
    @Injected(\.publishingService)
    private var publishingService: any PublishingServiceProtocol
    
    private let spaceId: String
    private let objectId: String
    
    init(data: PublishToWebViewData) {
        spaceId = data.spaceId
        objectId = data.objectId
        
        let participantStorage = Container.shared.accountParticipantsStorage()
        if let participant = participantStorage.participants.first {
            domain = participant.publishingDomain
        } else {
            anytypeAssertionFailure("No participants found for account")
            domain = ""
            state = .error(Loc.Publishing.Error.noDomain)
        }
        
        setupBindings()
    }
    
    func onAppear() async {
//        let status = try? await publishingService.getStatus(spaceId: spaceId, objectId: objectId)
        // TBD;
    }
    
    func onPublishTap() {
        // TBD;
    }
    
    private func setupBindings() {
        $customPath
            .map { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .assign(to: &$canPublish)
    }
}
