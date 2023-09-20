import Foundation
import SwiftUI

protocol WidgetObjectListModuleAssemblyProtocol: AnyObject {
    // TODO: Navigation: Delete BrowserBottomPanelManagerProtocol
    func makeFavorites(bottomPanelManager: BrowserBottomPanelManagerProtocol?, output: WidgetObjectListCommonModuleOutput?) -> AnyView
    func makerecentEdit(bottomPanelManager: BrowserBottomPanelManagerProtocol?, output: WidgetObjectListCommonModuleOutput?) -> AnyView
    func makeRecentOpen(bottomPanelManager: BrowserBottomPanelManagerProtocol?, output: WidgetObjectListCommonModuleOutput?) -> AnyView
    func makeSets(bottomPanelManager: BrowserBottomPanelManagerProtocol?, output: WidgetObjectListCommonModuleOutput?) -> AnyView
    func makeCollections(bottomPanelManager: BrowserBottomPanelManagerProtocol?, output: WidgetObjectListCommonModuleOutput?) -> AnyView
    func makeBin(bottomPanelManager: BrowserBottomPanelManagerProtocol?, output: WidgetObjectListCommonModuleOutput?) -> AnyView
    func makeFiles() -> AnyView
}

final class WidgetObjectListModuleAssembly: WidgetObjectListModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    private let uiHelpersDI: UIHelpersDIProtocol
    
    init(serviceLocator: ServiceLocator, uiHelpersDI: UIHelpersDIProtocol) {
        self.serviceLocator = serviceLocator
        self.uiHelpersDI = uiHelpersDI
    }
    
    // MARK: - WidgetObjectListModuleAssemblyProtocol
    
    func makeFavorites(bottomPanelManager: BrowserBottomPanelManagerProtocol?, output: WidgetObjectListCommonModuleOutput?) -> AnyView {
        return make(
            internalModel: WidgetObjectListFavoritesViewModel(
                favoriteSubscriptionService: self.serviceLocator.favoriteSubscriptionService(),
                activeWorkspaceStorage: self.serviceLocator.activeWorkspaceStorage(),
                documentService: self.serviceLocator.documentService(),
                objectActionService: self.serviceLocator.objectActionsService()
            ),
            bottomPanelManager: bottomPanelManager,
            output: output
        )
    }
    
    func makerecentEdit(bottomPanelManager: BrowserBottomPanelManagerProtocol?, output: WidgetObjectListCommonModuleOutput?) -> AnyView {
        return make(
            internalModel: WidgetObjectListRecentViewModel(
                type: .recentEdit,
                recentSubscriptionService: self.serviceLocator.recentSubscriptionService()
            ),
            bottomPanelManager: bottomPanelManager,
            output: output
        )
    }
    
    func makeRecentOpen(bottomPanelManager: BrowserBottomPanelManagerProtocol?, output: WidgetObjectListCommonModuleOutput?) -> AnyView {
        return make(
            internalModel: WidgetObjectListRecentViewModel(
                type: .recentOpen,
                recentSubscriptionService: self.serviceLocator.recentSubscriptionService()
            ),
            bottomPanelManager: bottomPanelManager,
            output: output
        )
    }
    
    func makeSets(bottomPanelManager: BrowserBottomPanelManagerProtocol?, output: WidgetObjectListCommonModuleOutput?) -> AnyView {
        return make(
            internalModel: WidgetObjectListSetsViewModel(setsSubscriptionService: self.serviceLocator.setsSubscriptionService()),
            bottomPanelManager: bottomPanelManager,
            output: output
        )
    }
    
    func makeCollections(bottomPanelManager: BrowserBottomPanelManagerProtocol?, output: WidgetObjectListCommonModuleOutput?) -> AnyView {
        return make(
            internalModel: WidgetObjectListCollectionsViewModel(subscriptionService: self.serviceLocator.collectionsSubscriptionService()),
            bottomPanelManager: bottomPanelManager,
            output: output
        )
    }
    
    func makeBin(bottomPanelManager: BrowserBottomPanelManagerProtocol?, output: WidgetObjectListCommonModuleOutput?) -> AnyView {
        return make(
            internalModel: WidgetObjectListBinViewModel(binSubscriptionService: self.serviceLocator.binSubscriptionService()),
            bottomPanelManager: bottomPanelManager,
            output: output
        )
    }
    
    func makeFiles() -> AnyView {
        return make(
            internalModel: WidgetObjectListFilesViewModel(subscriptionService: self.serviceLocator.filesSubscriptionManager()),
            bottomPanelManager: nil,
            output: nil,
            isSheet: true
        )
    }
    
    // MARK: - Private
    
    private func make(
        internalModel: @autoclosure @escaping () -> WidgetObjectListInternalViewModelProtocol,
        bottomPanelManager: BrowserBottomPanelManagerProtocol?,
        output: WidgetObjectListCommonModuleOutput?,
        isSheet: Bool = false
    ) -> AnyView {
        
        let view = WidgetObjectListView(model: WidgetObjectListViewModel(
            internalModel: internalModel(),
            bottomPanelManager: bottomPanelManager,
            objectActionService: self.serviceLocator.objectActionsService(),
            menuBuilder: WidgetObjectListMenuBuilder(),
            alertOpener: self.uiHelpersDI.alertOpener(),
            output: output,
            isSheet: isSheet
        ))
        return view.eraseToAnyView()
//        return WidgetObjectListHostingController(model: model, rootView: view)
    }
}
