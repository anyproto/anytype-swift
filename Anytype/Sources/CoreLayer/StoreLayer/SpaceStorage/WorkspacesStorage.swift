import Foundation
import Combine
import Services

protocol WorkspacesStorageProtocol: AnyObject {
    var workspaces: [ObjectDetails] { get }
    var workspsacesPublisher: AnyPublisher<[ObjectDetails], Never> { get }
    func startSubscription() async
    func stopSubscription()
}

final class WorkspacesStorage: WorkspacesStorageProtocol {
    
    // MARK: - DI
    
    private let subscriptionsService: SubscriptionsServiceProtocol
    private let subscriptionBuilder: WorkspacesSubscriptionBuilderProtocol
    
    // MARK: - State
    
    @Published private(set) var workspaces: [ObjectDetails] = []
    var workspsacesPublisher: AnyPublisher<[ObjectDetails], Never> { $workspaces.eraseToAnyPublisher() }
    
    init(subscriptionsService: SubscriptionsServiceProtocol, subscriptionBuilder: WorkspacesSubscriptionBuilderProtocol) {
        self.subscriptionsService = subscriptionsService
        self.subscriptionBuilder = subscriptionBuilder
    }
    
    func startSubscription() async {
        let data = subscriptionBuilder.build()
        await subscriptionsService.startSubscriptionAsync(data: data) { [weak self] _, update in
            self?.workspaces.applySubscriptionUpdate(update)
        }
    }
    
    func stopSubscription() {
        subscriptionsService.stopAllSubscriptions()
    }
}
