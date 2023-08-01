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
        let image: ObjectIconImage?
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
    
    private let activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    private let subscriptionService: SingleObjectSubscriptionServiceProtocol
    private let stateManager: HomeWidgetsStateManagerProtocol
    private let dashboardService: DashboardServiceProtocol
    private weak var output: HomeBottomPanelModuleOutput?
    
    // MARK: - State
    
    private var spaceDetails: ObjectDetails?
    private var workspaceSubscription: AnyCancellable?
    private var dataSubscriptions: [AnyCancellable] = []
    
    // MARK: - Public properties
    
    @Published var buttonState: ButtonState = .normal([])
    
    init(
        activeWorkspaceStorage: ActiveWorkpaceStorageProtocol,
        subscriptionService: SingleObjectSubscriptionServiceProtocol,
        stateManager: HomeWidgetsStateManagerProtocol,
        dashboardService: DashboardServiceProtocol,
        output: HomeBottomPanelModuleOutput?
    ) {
        self.activeWorkspaceStorage = activeWorkspaceStorage
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
                ImageButton(image: .imageAsset(.Widget.search), onTap: { [weak self] in
                    self?.output?.onSearchSelected()
                }),
                ImageButton(image: .imageAsset(.Widget.add), onTap: { [weak self] in
                    UISelectionFeedbackGenerator().selectionChanged()
                    self?.handleCreateObject()
                }),
                ImageButton(image: spaceDetails?.objectIconImage, onTap: { [weak self] in
                    self?.output?.onSettingsSelected()
                })
            ])
        }
    }
    
    private func setupSubscription() {
        workspaceSubscription = activeWorkspaceStorage.workspaceInfoPublisher
            .receiveOnMain()
            .sink { [weak self] info in
                self?.setupDataSubscription(workspaceInfo: info)
            }
    }
    
    private func setupDataSubscription(workspaceInfo: AccountInfo) {
        dataSubscriptions.removeAll()
        subscriptionService.stopSubscription(subIdPrefix: Constants.subId)
        
        subscriptionService.startSubscription(
            subIdPrefix: Constants.subId,
            objectId: workspaceInfo.workspaceObjectId
        ) { [weak self] details in
            self?.handleSpaceDetails(details: details)
        }
        
        stateManager.isEditStatePublisher
            .receiveOnMain()
            .sink { [weak self] in self?.updateModels(isEditState: $0) }
            .store(in: &dataSubscriptions)
    }
    
    private func handleSpaceDetails(details: ObjectDetails) {
        spaceDetails = details
        updateModels(isEditState: stateManager.isEditState)
    }
    
    private func handleCreateObject() {
        guard let spaceDetails else { return }
        Task { @MainActor in
            guard let details = try? await dashboardService.createNewPage(spaceId: spaceDetails.spaceId) else { return }
            AnytypeAnalytics.instance().logCreateObject(objectType: details.analyticsType, route: .navigation, view: .home)
            
            output?.onCreateObjectSelected(screenData: details.editorScreenData())
        }
    }
}
