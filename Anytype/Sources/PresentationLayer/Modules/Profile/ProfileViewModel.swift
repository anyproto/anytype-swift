import SwiftUI
import Services
import AnytypeCore


@MainActor
final class ProfileViewModel: ObservableObject {

    @Published var details: ObjectDetails?
    @Published var showSettings = false

    var pageNavigation: PageNavigation?

    var isOwner: Bool {
        accountManager.account.info.profileObjectID == details?.identityProfileLink
    }

    private let info: ObjectInfo

    @Injected(\.singleObjectSubscriptionService)
    private var subscriptionService: any SingleObjectSubscriptionServiceProtocol
    @Injected(\.accountManager)
    private var accountManager: any AccountManagerProtocol
    @Injected(\.workspaceService)
    private var workspaceService: any WorkspaceServiceProtocol
    @Injected(\.spaceViewsStorage)
    private var spaceViewsStorage: any SpaceViewsStorageProtocol

    private let subId = "ProfileViewModel-\(UUID().uuidString)"

    init(info: ObjectInfo) {
        self.info = info
    }

    func setupSubscriptions() async {
        async let subscription: () = subscribe()

        (_) = await (subscription)
    }

    func onConnect() async throws {
        guard let details, details.identity.isNotEmpty else {
            anytypeAssertionFailure("Identity is empty for on connect")
            return
        }

        if let existingSpace = spaceViewsStorage.oneToOneSpaceView(identity: details.identity) {
            pageNavigation?.open(.spaceChat(SpaceChatCoordinatorData(spaceId: existingSpace.targetSpaceId)))
            return
        }

        let newSpaceId = try await workspaceService.createOneToOneSpace(
            oneToOneIdentity: details.identity,
            metadataKey: details.oneToOneRequestMetadataKey
        )
        pageNavigation?.open(.spaceChat(SpaceChatCoordinatorData(spaceId: newSpaceId)))
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

    private func handleProfileDetails(_ details: ObjectDetails) async {
        self.details = details
    }
}
