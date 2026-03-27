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

    private let workspaceStorage: any SpaceViewsStorageProtocol = Container.shared.spaceViewsStorage()
    @Injected(\.stubWidgetDismissalStorage) @ObservationIgnored
    private var dismissalStorage: any StubWidgetDismissalStorageProtocol
    @ObservationIgnored
    private let participantsSubscription: ParticipantsSubscription

    // MARK: - State

    var showCreateHome = false
    var showInviteMembers = false

    // MARK: - Init

    init(spaceId: String, output: (any HomeWidgetsModuleOutput)?) {
        self.spaceId = spaceId
        self.output = output
        self.participantsSubscription = ParticipantsSubscription(spaceId: spaceId)
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
        dismissalStorage.setCreateHomeDismissed(spaceId: spaceId)
        showCreateHome = false
    }

    func onInviteMembersTap() {
        output?.onSpaceChatMembersSelected(spaceId: spaceId, route: .navigation)
    }

    func onInviteMembersClose() {
        dismissalStorage.setInviteMembersDismissed(spaceId: spaceId)
        showInviteMembers = false
    }

    // MARK: - Private

    private func startSpaceViewTask() async {
        for await spaceView in workspaceStorage.spaceViewPublisher(spaceId: spaceId).removeDuplicates().values {
            let homepageEmpty = spaceView.homepage == .empty

            // When homepage becomes non-empty (set from any client, including desktop),
            // reset the "Create Home" dismissal. This ensures the widget can reappear
            // if homepage is later reset to empty (e.g. the homepage object was deleted
            // and middleware cleared the value).
            if !homepageEmpty {
                dismissalStorage.resetCreateHomeDismissed(spaceId: spaceId)
            }

            let pickerDismissed = dismissalStorage.isHomepagePickerDismissed(spaceId: spaceId)
            let createHomeDismissed = dismissalStorage.isCreateHomeDismissed(spaceId: spaceId)

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

        let inviteMembersDismissed = dismissalStorage.isInviteMembersDismissed(spaceId: spaceId)
        guard !inviteMembersDismissed else {
            showInviteMembers = false
            return
        }

        for await participants in participantsSubscription.withoutRemovingParticipantsPublisher.values {
            let hasMembers = participants.count > 1
            showInviteMembers = FeatureFlags.createChannelFlow && !hasMembers
        }
    }
}
