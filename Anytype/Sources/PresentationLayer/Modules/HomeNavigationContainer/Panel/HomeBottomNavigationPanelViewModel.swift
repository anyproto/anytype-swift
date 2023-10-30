import Foundation
import Services
import Combine
import UIKit
import AnytypeCore

@MainActor
final class HomeBottomNavigationPanelViewModel: ObservableObject {
    
    // MARK: - Private properties
    
    private let activeWorkpaceStorage: ActiveWorkpaceStorageProtocol
    private let subscriptionService: SingleObjectSubscriptionServiceProtocol
    private let dashboardService: DashboardServiceProtocol
    private weak var output: HomeBottomNavigationPanelModuleOutput?
    private let subId = "HomeBottomNavigationProfile-\(UUID().uuidString)"
    
    // MARK: - Public properties
    
    @Published var isEditState: Bool = false
    @Published var profileIcon: Icon?
    
    init(
        activeWorkpaceStorage: ActiveWorkpaceStorageProtocol,
        subscriptionService: SingleObjectSubscriptionServiceProtocol,
        dashboardService: DashboardServiceProtocol,
        output: HomeBottomNavigationPanelModuleOutput?
    ) {
        self.activeWorkpaceStorage = activeWorkpaceStorage
        self.subscriptionService = subscriptionService
        self.dashboardService = dashboardService
        self.output = output
        setupDataSubscription()
    }
    
    func onTapForward() {
        output?.onForwardSelected()
    }
    
    func onTapBackward() {
        output?.onBackwardSelected()
    }
    
    func onTapNewObject() {
        handleCreateObject()
    }
    
    func onTapSearch() {
        output?.onSearchSelected()
    }
    
    func onTapHome() {
        output?.onHomeSelected()
    }
    
    func onTapProfile() {
        output?.onProfileSelected()
    }
        
    // MARK: - Private
    
    private func setupDataSubscription() {
        Task {
            await subscriptionService.startSubscription(
                subId: subId,
                objectId: activeWorkpaceStorage.workspaceInfo.profileObjectID
            ) { [weak self] details in
                self?.handleProfileDetails(details: details)
            }
        }
    }
    
    private func handleProfileDetails(details: ObjectDetails) {
        profileIcon = details.objectIconImage
    }
    
    private func handleCreateObject() {
        Task { @MainActor in
            guard let details = try? await dashboardService.createNewPage(spaceId: activeWorkpaceStorage.workspaceInfo.accountSpaceId) else { return }
            AnytypeAnalytics.instance().logCreateObject(objectType: details.analyticsType, route: .navigation, view: .home)
            
            output?.onCreateObjectSelected(screenData: details.editorScreenData())
        }
    }
}
