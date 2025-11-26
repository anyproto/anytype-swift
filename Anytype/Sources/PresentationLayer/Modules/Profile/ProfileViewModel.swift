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

    private let subId = "ProfileViewModel-\(UUID().uuidString)"

    init(info: ObjectInfo) {
        self.info = info
    }

    func setupSubscriptions() async {
        async let subscription: () = subscribe()

        (_) = await (subscription)
    }

    func onConnect() async {
        guard let identity = details?.identity, identity.isNotEmpty else { return }

        if let spaceId = try? await workspaceService.createOneToOneSpace(oneToOneIdentity: identity) {
            pageNavigation?.open(.spaceChat(SpaceChatCoordinatorData(spaceId: spaceId)))
        }
    }

    // MARK: - Private
    private func subscribe() async {

        await subscriptionService.startSubscription(
            subId: subId,
            spaceId: info.spaceId,
            objectId: info.objectId,
            additionalKeys: [.identity, .identityProfileLink, .globalName]
        ) { [weak self] details in
            await self?.handleProfileDetails(details)
        }
    }

    private func handleProfileDetails(_ details: ObjectDetails) async {
        self.details = details
    }
}
