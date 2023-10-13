import Foundation
import Services
import Combine
import UIKit
import AnytypeCore

@MainActor
final class HomeBottomPanelViewModel: ObservableObject {
    
    private enum Constants {
        static let subId = "HomeBottomSpace"
    }
    
    struct ImageButton: Hashable, Equatable {
        let image: Icon?
        let padding: Bool
        @EquatableNoop var onTap: () -> Void
        @EquatableNoop var onLongTap: (() -> Void)?
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
    
    private let info: AccountInfo
    private let subscriptionService: SingleObjectSubscriptionServiceProtocol
    private let stateManager: HomeWidgetsStateManagerProtocol
    private let dashboardService: DashboardServiceProtocol
    private weak var output: HomeBottomPanelModuleOutput?
    
    // MARK: - State
    
    private var profileDetails: ObjectDetails?
    private var workspaceSubscription: AnyCancellable?
    private var dataSubscriptions: [AnyCancellable] = []
    private let subId = "HomeBottomSpace-\(UUID().uuidString)"
    
    // MARK: - Public properties
    
    @Published var buttonState: ButtonState = .normal([])
    @Published var isEditState: Bool = false
    
    init(
        info: AccountInfo,
        subscriptionService: SingleObjectSubscriptionServiceProtocol,
        stateManager: HomeWidgetsStateManagerProtocol,
        dashboardService: DashboardServiceProtocol,
        output: HomeBottomPanelModuleOutput?
    ) {
        self.info = info
        self.subscriptionService = subscriptionService
        self.stateManager = stateManager
        self.dashboardService = dashboardService
        self.output = output
        Task {
            await setupDataSubscription()
        }
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
                }, onLongTap: nil),
                ImageButton(image: .asset(.Widget.add), padding: false, onTap: { [weak self] in
                    UISelectionFeedbackGenerator().selectionChanged()
                    self?.handleCreateObject()
                }, onLongTap: { [weak self] in
                    if FeatureFlags.selectTypeByLongTap {
                        UISelectionFeedbackGenerator().selectionChanged()
                        self?.output?.onCreateObjectWithTypeSelected()
                    }
                }),
                ImageButton(image: profileDetails?.objectIconImage, padding: true, onTap: { [weak self] in
                    if FeatureFlags.multiSpace {
                        self?.output?.onProfileSelected()
                    } else {
                        self?.output?.onSettingsSelected()
                    }
                }, onLongTap: nil)
            ])
        }
        self.isEditState = isEditState
    }
    
    private func setupDataSubscription() async {
        await subscriptionService.startSubscription(
            subId: subId,
            objectId: FeatureFlags.multiSpace ? info.profileObjectID : info.spaceViewId
        ) { [weak self] details in
            self?.handleProfileDetails(details: details)
        }
        
        stateManager.isEditStatePublisher
            .receiveOnMain()
            .sink { [weak self] in self?.updateModels(isEditState: $0) }
            .store(in: &dataSubscriptions)
    }
    
    private func handleProfileDetails(details: ObjectDetails) {
        profileDetails = details
        updateModels(isEditState: stateManager.isEditState)
    }
    
    private func handleCreateObject() {
        Task { @MainActor in
            guard let details = try? await dashboardService.createNewPage(spaceId: info.accountSpaceId) else { return }
            AnytypeAnalytics.instance().logCreateObject(objectType: details.analyticsType, route: .navigation, view: .home)
            
            output?.onCreateObjectSelected(screenData: details.editorScreenData())
        }
    }
}
