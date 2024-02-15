import Foundation
import Services

@MainActor
final class SpaceShareViewModel: ObservableObject {
    
    private enum Constants {
        static let participantLimit = 11 // 10 participants and 1 owner
    }
    
    private let participantSubscriptionService: ParticipantsSubscriptionServiceProtocol
    private let workspaceService: WorkspaceServiceProtocol
    private let activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    private let deppLinkParser: DeepLinkParserProtocol
    
    @Published var participants: [Participant] = []
    @Published var inviteLink: URL?
    @Published var shareInviteLink: URL?
    @Published var left: Int = 0
    
    init(
        participantSubscriptionService: ParticipantsSubscriptionServiceProtocol, 
        workspaceService: WorkspaceServiceProtocol,
        activeWorkspaceStorage: ActiveWorkpaceStorageProtocol,
        deppLinkParser: DeepLinkParserProtocol
    ) {
        self.participantSubscriptionService = participantSubscriptionService
        self.workspaceService = workspaceService
        self.activeWorkspaceStorage = activeWorkspaceStorage
        self.deppLinkParser = deppLinkParser
        startSubscriptions()
        Task {
            let invite = try await workspaceService.getCurrentInvite(spaceId: activeWorkspaceStorage.workspaceInfo.accountSpaceId)
            inviteLink = deppLinkParser.createUrl(deepLink: .invite(cid: invite.cid, key: invite.fileKey))
        }
    }
    
    func onUpdateLink() {
        
    }
    
    func onShareInvite() {
        shareInviteLink = inviteLink
    }
    
    // MARK: - Private
    
    private func startSubscriptions() {
        Task {
            await participantSubscriptionService.startSubscription { [weak self] items in
                self?.participants = items
                self?.left = Constants.participantLimit - items.count
            }
        }
    }
    
    deinit {
        Task { [participantSubscriptionService] in
            await participantSubscriptionService.stopSubscription()
        }
    }
}
