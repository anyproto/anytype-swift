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
        async let spaceViewTask: () = startSpaceViewTask()
        async let participantsTask: () = startParticipantsTask()
        _ = await (spaceViewTask, participantsTask)
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

    private func startSpaceViewTask() async {
        // If homepage is set, reset the "Create Home" dismissal once on entry.
        // This way, if homepage is later cleared (e.g. object deleted by middleware),
        // the widget will reappear on the next space visit.
        let initialSpaceView = workspaceStorage.spaceView(spaceId: spaceId)
        if initialSpaceView?.homepage != .empty {
            onboardingStorage.resetCreateHomeDismissed(spaceId: spaceId)
        }

        for await spaceView in workspaceStorage.spaceViewPublisher(spaceId: spaceId).removeDuplicates().values {
            let homepageEmpty = spaceView.homepage == .empty
            let pickerDismissed = onboardingStorage.isHomepagePickerDismissed(spaceId: spaceId)
            let createHomeDismissed = onboardingStorage.isCreateHomeDismissed(spaceId: spaceId)

            showCreateHome = FeatureFlags.createChannelFlow
                && homepageEmpty
                && pickerDismissed
                && !createHomeDismissed
        }
    }

    private func startParticipantsTask() async {
        let spaceView = workspaceStorage.spaceView(spaceId: spaceId)
        guard spaceView?.isShared ?? false else {
            showInviteMembers = false
            return
        }

        for await participants in participantsSubscription.withoutRemovingParticipantsPublisher.values {
            let hasMembers = participants.count > 1
            let inviteMembersDismissed = onboardingStorage.isInviteMembersDismissed(spaceId: spaceId)
            showInviteMembers = FeatureFlags.createChannelFlow && !hasMembers && !inviteMembersDismissed
        }
    }
}
