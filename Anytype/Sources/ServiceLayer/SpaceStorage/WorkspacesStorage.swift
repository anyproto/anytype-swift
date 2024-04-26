import Foundation
import Combine
import Services

@MainActor
protocol WorkspacesStorageProtocol: AnyObject {
    var allWorkspaces: [SpaceView] { get }
    var allWorkspsacesPublisher: AnyPublisher<[SpaceView], Never> { get }
    func startSubscription() async
    func stopSubscription() async
    func spaceView(spaceViewId: String) -> SpaceView?
    func spaceView(spaceId: String) -> SpaceView?
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
    
    private enum Constants {
        static let maxSpaces = 10
    }
    
    // MARK: - DI
    
    @Injected(\.workspacesSubscriptionBuilder)
    private var subscriptionBuilder: WorkspacesSubscriptionBuilderProtocol
    @Injected(\.subscriptionStorageProvider)
    private var subscriptionStorageProvider: SubscriptionStorageProviderProtocol
    private lazy var subscriptionStorage: SubscriptionStorageProtocol = {
        subscriptionStorageProvider.createSubscriptionStorage(subId: subscriptionBuilder.subscriptionId)
    }()
    
    // MARK: - State
    
    @Published private(set) var allWorkspaces: [SpaceView] = []
    var allWorkspsacesPublisher: AnyPublisher<[SpaceView], Never> { $allWorkspaces.eraseToAnyPublisher() }
    
    nonisolated init() {}
    
    func startSubscription() async {
        let data = subscriptionBuilder.build()
        try? await subscriptionStorage.startOrUpdateSubscription(data: data) { [weak self] data in
            guard let self else { return }
            allWorkspaces = data.items.map { SpaceView(details: $0) }
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
    
    func canCreateNewSpace() -> Bool {
        return activeWorkspaces.count < Constants.maxSpaces
    }
}
