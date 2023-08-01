import Foundation
import Services
import Combine
import UIKit

@MainActor
final class HomeBottomPanelViewModel: ObservableObject {
    
    private enum Constants {
        static let subId = "HomeBottomSpace"
    }
    
    struct ImageButton: Hashable, Equatable {
        let image: Icon?
        let padding: Bool
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
    
    private let accountManager: AccountManagerProtocol
    private let subscriptionService: SingleObjectSubscriptionServiceProtocol
    private let stateManager: HomeWidgetsStateManagerProtocol
    private let dashboardService: DashboardServiceProtocol
    private weak var output: HomeBottomPanelModuleOutput?
    
    // MARK: - State
    
    private var spaceDetails: ObjectDetails?
    private var subscriptions: [AnyCancellable] = []
    
    // MARK: - Public properties
    
    @Published var buttonState: ButtonState = .normal([])
    
    init(
        accountManager: AccountManagerProtocol,
        subscriptionService: SingleObjectSubscriptionServiceProtocol,
        stateManager: HomeWidgetsStateManagerProtocol,
        dashboardService: DashboardServiceProtocol,
        output: HomeBottomPanelModuleOutput?
    ) {
        self.accountManager = accountManager
        self.subscriptionService = subscriptionService
        self.stateManager = stateManager
        self.dashboardService = dashboardService
        self.output = output
        setupSubscription()
    }
        
    // MARK: - Private
    
    private func updateModels(isEditState: Bool) {
        if isEditState {
            buttonState = .edit([
                TexButton(text: Loc.add, onTap: { [weak self] in
                    AnytypeAnalytics.instance().logAddWidget(context: .editor)
                    self?.output?.onCreateWidgetSelected(context: .editor)
                }),
                TexButton(text: Loc.done, onTap: { [weak self] in
                    self?.stateManager.setEditState(false)
                })
            ])
        } else {
            buttonState = .normal([
                ImageButton(image: .asset(.Widget.search), padding: false, onTap: { [weak self] in
                    self?.output?.onSearchSelected()
                }),
                ImageButton(image: .asset(.Widget.add), padding: false, onTap: { [weak self] in
                    UISelectionFeedbackGenerator().selectionChanged()
                    self?.handleCreateObject()
                }),
                ImageButton(image: spaceDetails?.objectIconImage, padding: true, onTap: { [weak self] in
                    self?.output?.onSettingsSelected()
                })
            ])
        }
    }
    
    private func setupSubscription() {
        subscriptionService.startSubscription(
            subIdPrefix: Constants.subId,
            objectId: accountManager.account.info.accountSpaceId
        ) { [weak self] details in
            self?.handleSpaceDetails(details: details)
        }
        
        stateManager.isEditStatePublisher
            .sink { [weak self] in self?.updateModels(isEditState: $0) }
            .store(in: &subscriptions)
    }
    
    private func handleSpaceDetails(details: ObjectDetails) {
        spaceDetails = details
        updateModels(isEditState: stateManager.isEditState)
    }
    
    private func handleCreateObject() {
        Task { @MainActor in
            guard let details = try? await dashboardService.createNewPage() else { return }
            AnytypeAnalytics.instance().logCreateObject(objectType: details.analyticsType, route: .navigation, view: .home)
            
            output?.onCreateObjectSelected(screenData: details.editorScreenData())
        }
    }
}
