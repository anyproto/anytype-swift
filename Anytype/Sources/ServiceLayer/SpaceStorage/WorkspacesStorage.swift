import Foundation
import Combine
import Services

@MainActor
protocol WorkspacesStorageProtocol: AnyObject {
    var workspaces: [SpaceView] { get }
    var workspsacesPublisher: AnyPublisher<[SpaceView], Never> { get }
    func startSubscription() async
    func stopSubscription() async
    func spaceView(spaceViewId: String) -> SpaceView?
    func spaceView(spaceId: String) -> SpaceView?
    func canCreateNewSpace() -> Bool
}

@MainActor
final class WorkspacesStorage: WorkspacesStorageProtocol {
    
    private enum Constants {
        static let maxSpaces = 10
    }
    
    // MARK: - DI
    
    private var subscriptionStorage: SubscriptionStorageProtocol
    private let subscriptionBuilder: WorkspacesSubscriptionBuilderProtocol
    
    // MARK: - State
    
    @Published private(set) var workspaces: [SpaceView] = []
    var workspsacesPublisher: AnyPublisher<[SpaceView], Never> { $workspaces.eraseToAnyPublisher() }
    
    nonisolated init(
        subscriptionStorageProvider: SubscriptionStorageProviderProtocol,
        subscriptionBuilder: WorkspacesSubscriptionBuilderProtocol
    ) {
        self.subscriptionStorage = subscriptionStorageProvider.createSubscriptionStorage(subId: subscriptionBuilder.subscriptionId)
        self.subscriptionBuilder = subscriptionBuilder
    }
    
    func startSubscription() async {
        let data = subscriptionBuilder.build()
        try? await subscriptionStorage.startOrUpdateSubscription(data: data) { [weak self] data in
            guard let self else { return }
            workspaces = data.items.map { SpaceView(details: $0) }
        }
    }
    
    func stopSubscription() async {
        try? await subscriptionStorage.stopSubscription()
    }
    
    func spaceView(spaceViewId: String) -> SpaceView? {
        return workspaces.first(where: { $0.id == spaceViewId })
    }
    
    func spaceView(spaceId: String) -> SpaceView? {
        return workspaces.first(where: { $0.targetSpaceId == spaceId })
    }
    
    func canCreateNewSpace() -> Bool {
        return workspaces.count < Constants.maxSpaces
    }
}
