import SwiftUI
import Services
import AnytypeCore


@MainActor
@Observable
final class ProfileViewModel {

    var details: ObjectDetails?
    var showSettings = false
    var canRemoveMember = false
    var removeAlertModel: SpaceParticipantRemoveViewModel?

    @ObservationIgnored
    var pageNavigation: PageNavigation?

    @ObservationIgnored
    var onParticipantRemoved: (() -> Void)?

    var isOwner: Bool {
        accountManager.account.info.profileObjectID == details?.identityProfileLink
    }

    @ObservationIgnored
    private let info: ObjectInfo

    @ObservationIgnored @Injected(\.singleObjectSubscriptionService)
    private var subscriptionService: any SingleObjectSubscriptionServiceProtocol
    @ObservationIgnored @Injected(\.accountManager)
    private var accountManager: any AccountManagerProtocol
    @ObservationIgnored @Injected(\.workspaceService)
    private var workspaceService: any WorkspaceServiceProtocol
    @ObservationIgnored @Injected(\.spaceViewsStorage)
    private var spaceViewsStorage: any SpaceViewsStorageProtocol
    @ObservationIgnored @Injected(\.participantSpacesStorage)
    private var participantSpacesStorage: any ParticipantSpacesStorageProtocol
    @ObservationIgnored
    private lazy var participantsSubscription: any ParticipantsSubscriptionProtocol = Container.shared.participantSubscription(info.spaceId)

    @ObservationIgnored
    private var actorSpaceView: ParticipantSpaceViewData?
    @ObservationIgnored
    private var targetParticipant: Participant?

    @ObservationIgnored
    private let subId = "ProfileViewModel-\(UUID().uuidString)"

    init(info: ObjectInfo) {
        self.info = info
    }

    func setupSubscriptions() async {
        async let detailsSubscription: () = subscribe()
        async let spaceViewSubscription: () = startSpaceViewTask()
        async let participantsSubscription: () = startParticipantsTask()

        (_, _, _) = await (detailsSubscription, spaceViewSubscription, participantsSubscription)
    }

    func onConnect() async throws {
        guard let details, details.identity.isNotEmpty else {
            anytypeAssertionFailure("Identity is empty for on connect")
            return
        }

        AnytypeAnalytics.instance().logClickConnectOneToOne()

        if let existingSpace = spaceViewsStorage.oneToOneSpaceView(identity: details.identity) {
            pageNavigation?.open(.spaceChat(SpaceChatCoordinatorData(spaceId: existingSpace.targetSpaceId)))
            return
        }

        let newSpaceId = try await workspaceService.createOneToOneSpace(
            oneToOneIdentity: details.identity,
            metadataKey: details.oneToOneRequestMetadataKey
        )
        AnytypeAnalytics.instance().logCreateSpace(spaceId: newSpaceId, spaceType: .oneToOne, route: .profile)
        pageNavigation?.open(.spaceChat(SpaceChatCoordinatorData(spaceId: newSpaceId)))
    }

    func onRemoveMember() {
        guard let target = targetParticipant else { return }
        removeAlertModel = SpaceParticipantRemoveViewModel(
            onConfirm: { [weak self] in
                AnytypeAnalytics.instance().logRemoveSpaceMember()
                try await self?.workspaceService.participantRemove(
                    spaceId: target.spaceId,
                    identity: target.identity
                )
                self?.onParticipantRemoved?()
            }
        )
    }

    // MARK: - Private
    private func subscribe() async {

        await subscriptionService.startSubscription(
            subId: subId,
            spaceId: info.spaceId,
            objectId: info.objectId,
            additionalKeys: [.identity, .identityProfileLink, .globalName, .oneToOneRequestMetadataKey]
        ) { [weak self] details in
            await self?.handleProfileDetails(details)
        }
    }

    private func startSpaceViewTask() async {
        for await spaceView in participantSpacesStorage.participantSpaceViewPublisher(spaceId: info.spaceId).values {
            actorSpaceView = spaceView
            updateRemoveCapability()
        }
    }

    private func startParticipantsTask() async {
        for await items in participantsSubscription.withoutRemovingParticipantsPublisher.values {
            targetParticipant = items.first { $0.id == info.objectId }
            updateRemoveCapability()
        }
    }

    private func updateRemoveCapability() {
        guard let actorSpaceView, let target = targetParticipant else {
            canRemoveMember = false
            return
        }
        canRemoveMember = actorSpaceView.canRemove(target: target)
    }

    private func handleProfileDetails(_ details: ObjectDetails) async {
        self.details = details
    }
}
