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
        let identity = participantStorage.participants.first?.identity
        if let identity {
            domain = "\(identity).any.org" // TODO: or any.coop
        } else {
            anytypeAssertionFailure("No participants for account")
            domain = ""
            state = .error("Failed to load your domain. Please try again.")
        }
        
        setupBindings()
    }
    
    func onAppear() async {
        let status = try? await publishingService.getStatus(spaceId: spaceId, objectId: objectId)
        
        print(status)
    }
    
    func onPublishTap() {
        
    }
    
    private func setupBindings() {
        $customPath
            .map { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .assign(to: &$canPublish)
    }
}
