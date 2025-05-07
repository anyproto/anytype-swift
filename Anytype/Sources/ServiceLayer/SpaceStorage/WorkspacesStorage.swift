import Foundation
import Combine
import Services
import AnytypeCore

protocol WorkspacesStorageProtocol: AnyObject, Sendable {
    var allWorkspaces: [SpaceView] { get }
    var allWorkspsacesPublisher: AnyPublisher<[SpaceView], Never> { get }
    func startSubscription() async
    func stopSubscription() async
    func spaceView(spaceViewId: String) -> SpaceView?
    func spaceView(spaceId: String) -> SpaceView?
    func workspaceInfo(spaceId: String) -> AccountInfo?
    // TODO: Kostyl. Waiting when middleware to add method for receive account info without set active space
    func addWorkspaceInfo(spaceId: String, info: AccountInfo)
    
    func canCreateNewSpace() -> Bool
    
    // TODO: Remove with SpacePin toggle
    func move(space: SpaceView, after: SpaceView) async
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

final class WorkspacesStorage: WorkspacesStorageProtocol {
    // MARK: - DI
    
    private let subscriptionBuilder: any WorkspacesSubscriptionBuilderProtocol = Container.shared.workspacesSubscriptionBuilder()
    private let subscriptionStorageProvider: any SubscriptionStorageProviderProtocol = Container.shared.subscriptionStorageProvider()
    private let subscriptionStorage: any SubscriptionStorageProtocol
    private let accountManager: any AccountManagerProtocol = Container.shared.accountManager()
    
    private let customOrderBuilder: some CustomSpaceOrderBuilderProtocol = CustomSpaceOrderBuilder()
    
    // MARK: - State

    private let workspacesInfo = SynchronizedDictionary<String, AccountInfo>()
    
    private let allWorkspacesStorage = AtomicPublishedStorage<[SpaceView]>([])
    var allWorkspaces: [SpaceView] { allWorkspacesStorage.value }
    var allWorkspsacesPublisher: AnyPublisher<[SpaceView], Never> {
        allWorkspacesStorage.publisher
            .throttle(for: .milliseconds(50), scheduler: DispatchQueue.global(), latest: true)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    init() {
        self.subscriptionStorage = subscriptionStorageProvider.createSubscriptionStorage(subId: subscriptionBuilder.subscriptionId)
    }
    
    func startSubscription() async {
        let data = subscriptionBuilder.build(techSpaceId: accountManager.account.info.techSpaceId)
        try? await subscriptionStorage.startOrUpdateSubscription(data: data) { [weak self] data in
            guard let self else { return }
            
            var spaces = data.items.map { SpaceView(details: $0) }
            spaces = customOrderBuilder.updateSpacesList(spaces: spaces)
            
            allWorkspacesStorage.value = spaces
        }
    }
    
    func stopSubscription() async {
        try? await subscriptionStorage.stopSubscription()
    }
    
    func spaceView(spaceViewId: String) -> SpaceView? {
        return allWorkspacesStorage.value.first(where: { $0.id == spaceViewId })
    }
    
    func spaceView(spaceId: String) -> SpaceView? {
        return allWorkspacesStorage.value.first(where: { $0.targetSpaceId == spaceId })
    }
    
    func move(space: SpaceView, after: SpaceView) {
        allWorkspacesStorage.value = customOrderBuilder.move(space: space, after: after, allSpaces: allWorkspaces)
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
