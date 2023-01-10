import Foundation
import BlocksModels

@MainActor
final class HomeWidgetsBottomPanelViewModel: ObservableObject {
    
    struct Button: Identifiable {
        let id: String
        let image: ObjectIconImage
        let onTap: () -> Void
    }
    
    // MARK: - Private properties
    
    private let toastPresenter: ToastPresenterProtocol
    private let accountManager: AccountManager
    private let subscriptionService: SubscriptionsServiceProtocol
    private let subscriotionBuilder: HomeWidgetsBottomSubscriptionDataBuilderProtocol
    private var subscriptionData: [ObjectDetails] = []
    
    // MARK: - Public properties
    
    @Published var buttons: [Button] = []
    
    init(
        toastPresenter: ToastPresenterProtocol,
        accountManager: AccountManager,
        subscriptionService: SubscriptionsServiceProtocol,
        subscriotionBuilder: HomeWidgetsBottomSubscriptionDataBuilderProtocol
    ) {
        self.toastPresenter = toastPresenter
        self.accountManager = accountManager
        self.subscriptionService = subscriptionService
        self.subscriotionBuilder = subscriotionBuilder
        updateModels()
        setupSubscription()
    }
        
    // MARK: - Private
    
    private func updateModels() {
        buttons = [
            HomeWidgetsBottomPanelViewModel.Button(id: "search", image: .imageAsset(.Widget.search), onTap: { [weak self] in
                self?.toastPresenter.show(message: "On tap search")
            }),
            HomeWidgetsBottomPanelViewModel.Button(id: "new", image: .imageAsset(.Widget.add), onTap: { [weak self] in
                self?.toastPresenter.show(message: "On tap create object")
            }),
            HomeWidgetsBottomPanelViewModel.Button(id: "space", image: subscriptionData.first?.objectIconImage ?? .placeholder(nil), onTap: { [weak self] in
                self?.toastPresenter.show(message: "On tap space")
           })
        ]
    }
    
    private func setupSubscription() {
        let data = subscriotionBuilder.build(objectId: accountManager.account.info.accountSpaceId)
        subscriptionService.startSubscription(data: data, update: { [weak self] in self?.handleEvent(update: $1) })
    }
    
    private func handleEvent(update: SubscriptionUpdate) {
        subscriptionData.applySubscriptionUpdate(update)
        updateModels()
    }
}
