import Foundation
import Services
import UIKit

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
    @Published var limitTitle: String = ""
    @Published var activeShareButton = false
    @Published var toastBarData: ToastBarData = .empty
    
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
    
    func onCopyLink() {
        UIPasteboard.general.string = inviteLink?.absoluteString
        toastBarData = ToastBarData(text: Loc.copied, showSnackBar: true)
    }
    
    // MARK: - Private
    
    private func startSubscriptions() {
        Task {
            await participantSubscriptionService.startSubscription { [weak self] items in
                self?.updateParticipant(items: items)
            }
        }
    }
    
    private func updateParticipant(items: [Participant]) {
        participants = items
        let limit = Constants.participantLimit - items.count
        activeShareButton = Constants.participantLimit > items.count
        limitTitle = activeShareButton ? Loc.SpaceShare.Invite.members(limit) : Loc.SpaceShare.Invite.maxLimit(Constants.participantLimit)
    }
    
    deinit {
        Task { [participantSubscriptionService] in
            await participantSubscriptionService.stopSubscription()
        }
    }
}
