import Foundation
import Combine
import Services
import AnytypeCore


@MainActor
protocol WorkspacesStorageProtocol: AnyObject {
    var allWorkspaces: [SpaceView] { get }
    var allWorkspsacesPublisher: AnyPublisher<[SpaceView], Never> { get }
    func startSubscription() async
    func stopSubscription() async
    func spaceView(spaceViewId: String) -> SpaceView?
    func spaceView(spaceId: String) -> SpaceView?
    func move(space: SpaceView, after: SpaceView)
    func workspaceInfo(spaceId: String) -> AccountInfo?
    // TODO: Kostyl. Waiting when middleware to add method for receive account info without set active space
    func addWorkspaceInfo(spaceId: String, info: AccountInfo)
    
    func canCreateNewSpace() -> Bool
}

extension WorkspacesStorageProtocol {
    
    var activeWorkspaces: [SpaceView] {
        allWorkspaces.filter(\.isActive)
    }
    
    var activeWorkspsacesPublisher: AnyPublisher<[SpaceView], Never> {
        allWorkspsacesPublisher.map { $0.filter(\.isActive) }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    func spaceViewPublisher(spaceId: String) -> AnyPublisher<SpaceView, Never> {
        allWorkspsacesPublisher.compactMap { $0.first { $0.targetSpaceId == spaceId } }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}

@MainActor
final class WorkspacesStorage: WorkspacesStorageProtocol {
    // MARK: - DI
    
    @Injected(\.workspacesSubscriptionBuilder)
    private var subscriptionBuilder: any WorkspacesSubscriptionBuilderProtocol
    @Injected(\.subscriptionStorageProvider)
    private var subscriptionStorageProvider: any SubscriptionStorageProviderProtocol
    private lazy var subscriptionStorage: any SubscriptionStorageProtocol = {
        subscriptionStorageProvider.createSubscriptionStorage(subId: subscriptionBuilder.subscriptionId)
    }()
    @Injected(\.accountManager)
    private var accountManager: any AccountManagerProtocol
    
    private let customOrderBuilder: some CustomSpaceOrderBuilderProtocol = CustomSpaceOrderBuilder()
    
    // MARK: - State

    private var workspacesInfo: [String: AccountInfo] = [:]
    
    @Published private(set) var allWorkspaces: [SpaceView] = []
    var allWorkspsacesPublisher: AnyPublisher<[SpaceView], Never> { $allWorkspaces.eraseToAnyPublisher() }
    
    nonisolated init() {}
    
    func startSubscription() async {
        let data = subscriptionBuilder.build(techSpaceId: accountManager.account.info.techSpaceId)
        try? await subscriptionStorage.startOrUpdateSubscription(data: data) { [weak self] data in
            guard let self else { return }
            let spaces = data.items.map { SpaceView(details: $0) }
            allWorkspaces = customOrderBuilder.updateSpacesList(spaces: spaces)
        }
    }
    
    func stopSubscription() async {
        try? await subscriptionStorage.stopSubscription()
    }
    
    func spaceView(spaceViewId: String) -> SpaceView? {
        return allWorkspaces.first(where: { $0.id == spaceViewId })
    }
    
    func spaceView(spaceId: String) -> SpaceView? {
        return allWorkspaces.first(where: { $0.targetSpaceId == spaceId })
    }
    
    func move(space: SpaceView, after: SpaceView) {
        allWorkspaces = customOrderBuilder.move(space: space, after: after, allSpaces: allWorkspaces)
    }
    
    func workspaceInfo(spaceId: String) -> AccountInfo? {
        workspacesInfo[spaceId]
    }
    
    func addWorkspaceInfo(spaceId: String, info: AccountInfo) {
        workspacesInfo[spaceId] = info
    }
    
    func canCreateNewSpace() -> Bool {
        return activeWorkspaces.count < 50
    }
}
