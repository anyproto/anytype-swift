import Foundation
import Services
import AnytypeCore
import Combine

@MainActor
@Observable
final class InviteMembersStubWidgetViewModel {

    private let spaceId: String
    @ObservationIgnored
    private weak var output: (any HomeWidgetsModuleOutput)?

    @Injected(\.spaceViewsStorage) @ObservationIgnored
    private var workspaceStorage: any SpaceViewsStorageProtocol
    @Injected(\.channelOnboardingStorage) @ObservationIgnored
    private var onboardingStorage: any ChannelOnboardingStorageProtocol
    @Injected(\.pendingShareStorage) @ObservationIgnored
    private var pendingShareStorage: any PendingShareStorageProtocol
    @ObservationIgnored
    private let participantsSubscription: any ParticipantsSubscriptionProtocol

    var showInviteMembers = false

    init(spaceId: String, output: (any HomeWidgetsModuleOutput)?) {
        self.spaceId = spaceId
        self.output = output
        self.participantsSubscription = Container.shared.participantSubscription(spaceId)
    }

    func startSubscription() async {
        guard !onboardingStorage.isInviteMembersDismissed(spaceId: spaceId) else { return }

        let isShared = workspaceStorage.spaceViewPublisher(spaceId: spaceId)
            .map(\.isShared)
            .removeDuplicates()

        let hasMembers = participantsSubscription.withoutRemovingParticipantsPublisher
            .map { $0.count > 1 }
            .removeDuplicates()

        for await (isShared, hasMembers) in isShared.combineLatest(hasMembers).values {
            let hasPendingMembers = pendingShareStorage.pendingState(for: spaceId)?.identities.isNotEmpty ?? false
            let dismissed = onboardingStorage.isInviteMembersDismissed(spaceId: spaceId)
            showInviteMembers = FeatureFlags.createChannelFlow
                && isShared
                && !hasMembers
                && !hasPendingMembers
                && !dismissed
            if dismissed { break }
        }
    }

    func onInviteMembersTap() {
        output?.onSpaceChatMembersSelected(spaceId: spaceId, route: .navigation)
    }

    func onInviteMembersClose() {
        onboardingStorage.setInviteMembersDismissed(spaceId: spaceId)
        showInviteMembers = false
    }
}
