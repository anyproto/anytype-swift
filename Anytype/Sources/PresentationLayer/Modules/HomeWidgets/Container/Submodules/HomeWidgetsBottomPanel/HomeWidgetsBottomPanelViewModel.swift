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
    private var subscriptionData: [ObjectDetails] = []
    
    // MARK: - Public properties
    
    @Published var buttons: [Button] = []
    
    init(
        toastPresenter: ToastPresenterProtocol,
        accountManager: AccountManager,
        subscriptionService: SubscriptionsServiceProtocol
    ) {
        self.toastPresenter = toastPresenter
        self.accountManager = accountManager
        self.subscriptionService = subscriptionService
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
        let data = SubscriptionData.objects(
            SubscriptionData.Object(
                identifier: SubscriptionId(value: "aaaa"),
                objectIds: [accountManager.account.info.accountSpaceId],
                keys: [
                    BundledRelationKey.id.rawValue,
                    BundledRelationKey.name.rawValue,
                    BundledRelationKey.snippet.rawValue,
                    BundledRelationKey.links.rawValue,
                    BundledRelationKey.type.rawValue,
                    BundledRelationKey.layout.rawValue,
                    BundledRelationKey.iconImage.rawValue,
                    BundledRelationKey.iconEmoji.rawValue,
                    BundledRelationKey.isDeleted.rawValue,
                    BundledRelationKey.isArchived.rawValue,
                ]
                    
            ))
        
        subscriptionService.startSubscription(data: data, update: { [weak self] in self?.handleEvent(update: $1) })
    }
    
    private func handleEvent(update: SubscriptionUpdate) {
        subscriptionData.applySubscriptionUpdate(update)
        updateModels()
    }
}
