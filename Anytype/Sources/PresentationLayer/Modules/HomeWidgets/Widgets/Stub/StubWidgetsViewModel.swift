import Foundation
import Services
import AnytypeCore
import Combine

@MainActor
@Observable
final class StubWidgetsViewModel {

    // MARK: - DI

    private let spaceId: String
    @ObservationIgnored
    private weak var output: (any HomeWidgetsModuleOutput)?

    @Injected(\.spaceViewsStorage) @ObservationIgnored
    private var workspaceStorage: any SpaceViewsStorageProtocol
    @Injected(\.channelOnboardingStorage) @ObservationIgnored
    private var onboardingStorage: any ChannelOnboardingStorageProtocol
    @Injected(\.pendingShareStorage) @ObservationIgnored
    private var pendingShareStorage: any PendingShareStorageProtocol
    @Injected(\.participantSpacesStorage) @ObservationIgnored
    private var participantSpacesStorage: any ParticipantSpacesStorageProtocol
    @ObservationIgnored
    private let participantsSubscription: any ParticipantsSubscriptionProtocol

    // MARK: - State

    var showCreateHome = false
    var showInviteMembers = false

    // MARK: - Init

    init(spaceId: String, output: (any HomeWidgetsModuleOutput)?) {
        self.spaceId = spaceId
        self.output = output
        // ParameterFactory requires spaceId — can't use @Injected
        self.participantsSubscription = Container.shared.participantSubscription(spaceId)
    }

    // MARK: - Subscriptions

    func startSubscriptions() async {
        async let createHome: () = subscribeToSpaceAndPermissionChanges()
        async let inviteMembers: () = subscribeToInviteMembersChanges()
        async let onboarding: () = subscribeToOnboardingChanges()
        _ = await (createHome, inviteMembers, onboarding)
    }

    // MARK: - Actions

    func onCreateHomeTap() {
        output?.onShowHomepagePicker()
    }

    func onCreateHomeClose() {
        onboardingStorage.setCreateHomeDismissed(spaceId: spaceId)
        showCreateHome = false
    }

    func onInviteMembersTap() {
        output?.onSpaceChatMembersSelected(spaceId: spaceId, route: .navigation)
    }

    func onInviteMembersClose() {
        onboardingStorage.setInviteMembersDismissed(spaceId: spaceId)
        showInviteMembers = false
    }

    // MARK: - Private

    private func subscribeToSpaceAndPermissionChanges() async {
        // If homepage is set, reset the "Create Home" dismissal once on entry.
        // This way, if homepage is later cleared (e.g. object deleted by middleware),
        // the widget will reappear on the next space visit.
        let initialSpaceView = workspaceStorage.spaceView(spaceId: spaceId)
        if initialSpaceView?.homepage != .empty {
            onboardingStorage.resetCreateHomeDismissed(spaceId: spaceId)
        }

        // participantSpaceViewPublisher covers both space view changes (homepage, name, etc.)
        // and current user's permission changes (viewer/editor promotion/demotion)
        for await _ in participantSpacesStorage.participantSpaceViewPublisher(spaceId: spaceId).values {
            recalculateShowCreateHome()
        }
    }

    private func subscribeToOnboardingChanges() async {
        for await _ in onboardingStorage.didChangePublisher.values {
            recalculateShowCreateHome()
        }
    }

    private func recalculateShowCreateHome() {
        let canSetHomepage = participantSpacesStorage.participantSpaceView(spaceId: spaceId)?.canSetHomepage ?? false
        let spaceView = workspaceStorage.spaceView(spaceId: spaceId)
        let homepageEmpty = spaceView?.homepage == .empty
        let pickerDismissed = onboardingStorage.isHomepagePickerDismissed(spaceId: spaceId)
        let createHomeDismissed = onboardingStorage.isCreateHomeDismissed(spaceId: spaceId)

        showCreateHome = FeatureFlags.createChannelFlow
            && canSetHomepage
            && homepageEmpty
            && pickerDismissed
            && !createHomeDismissed
    }

    private func subscribeToInviteMembersChanges() async {
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
}
