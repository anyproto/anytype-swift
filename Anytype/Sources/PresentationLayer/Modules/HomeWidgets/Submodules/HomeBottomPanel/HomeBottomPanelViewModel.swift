import Foundation
import BlocksModels
import Combine

@MainActor
final class HomeBottomPanelViewModel: ObservableObject {
    
    struct ImageButton: Hashable, Equatable {
        let image: ObjectIconImage
        @EquatableNoop var onTap: () -> Void
    }
    
    struct TexButton: Hashable, Equatable {
        let text: String
        @EquatableNoop var onTap: () -> Void
    }
    
    enum ButtonState: Equatable {
        case normal(_ buttons: [ImageButton])
        case edit(_ buttons: [TexButton])
    }
    
    // MARK: - Private properties
    
    private let toastPresenter: ToastPresenterProtocol
    private let accountManager: AccountManager
    private let subscriptionService: SubscriptionsServiceProtocol
    private let subscriotionBuilder: HomeBottomPanelSubscriptionDataBuilderProtocol
    private let stateManager: HomeWidgetsStateManagerProtocol
    private weak var output: HomeBottomPanelModuleOutput?
    
    // MARK: - State
    
    private var subscriptionData: [ObjectDetails] = []
    private var subscriptions: [AnyCancellable] = []
    
    // MARK: - Public properties
    
    @Published var buttonState: ButtonState = .normal([])
    
    init(
        toastPresenter: ToastPresenterProtocol,
        accountManager: AccountManager,
        subscriptionService: SubscriptionsServiceProtocol,
        subscriotionBuilder: HomeBottomPanelSubscriptionDataBuilderProtocol,
        stateManager: HomeWidgetsStateManagerProtocol,
        output: HomeBottomPanelModuleOutput?
    ) {
        self.toastPresenter = toastPresenter
        self.accountManager = accountManager
        self.subscriptionService = subscriptionService
        self.subscriotionBuilder = subscriotionBuilder
        self.stateManager = stateManager
        self.output = output
        setupSubscription()
    }
        
    // MARK: - Private
    
    private func updateModels(isEditState: Bool) {
        if isEditState {
            buttonState = .edit([
                TexButton(text: Loc.add, onTap: { [weak self] in
                    self?.output?.onCreateWidgetSelected()
                }),
                TexButton(text: Loc.done, onTap: { [weak self] in
                    self?.stateManager.setEditState(false)
                })
            ])
        } else {
            buttonState = .normal([
                ImageButton(image: .imageAsset(.Widget.search), onTap: { [weak self] in
                    self?.toastPresenter.show(message: "On tap search")
                }),
                ImageButton(image: .imageAsset(.Widget.add), onTap: { [weak self] in
                    self?.toastPresenter.show(message: "On tap create object")
                }),
                ImageButton(image: subscriptionData.first?.objectIconImage ?? .imageAsset(.Widget.spacePlaceholder), onTap: { [weak self] in
                    self?.toastPresenter.show(message: "On tap space")
                })
            ])
        }
    }
    
    private func setupSubscription() {
        let data = subscriotionBuilder.build(objectId: accountManager.account.info.accountSpaceId)
        subscriptionService.startSubscription(data: data, update: { [weak self] in self?.handleEvent(update: $1) })
        
        stateManager.isEditStatePublisher
            .sink { [weak self] in self?.updateModels(isEditState: $0) }
            .store(in: &subscriptions)
    }
    
    private func handleEvent(update: SubscriptionUpdate) {
        subscriptionData.applySubscriptionUpdate(update)
        updateModels(isEditState: stateManager.isEditState)
    }
}
