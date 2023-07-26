import Foundation
import SwiftUI

protocol WidgetObjectListModuleAssemblyProtocol: AnyObject {
    func makeFavorites(bottomPanelManager: BrowserBottomPanelManagerProtocol, output: WidgetObjectListCommonModuleOutput?) -> UIViewController
    func makeRecent(bottomPanelManager: BrowserBottomPanelManagerProtocol, output: WidgetObjectListCommonModuleOutput?) -> UIViewController
    func makeSets(bottomPanelManager: BrowserBottomPanelManagerProtocol, output: WidgetObjectListCommonModuleOutput?) -> UIViewController
    func makeCollections(bottomPanelManager: BrowserBottomPanelManagerProtocol, output: WidgetObjectListCommonModuleOutput?) -> UIViewController
    func makeBin(bottomPanelManager: BrowserBottomPanelManagerProtocol, output: WidgetObjectListCommonModuleOutput?) -> UIViewController
    func makeFiles() -> UIViewController
}

final class WidgetObjectListModuleAssembly: WidgetObjectListModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    private let uiHelpersDI: UIHelpersDIProtocol
    
    init(serviceLocator: ServiceLocator, uiHelpersDI: UIHelpersDIProtocol) {
        self.serviceLocator = serviceLocator
        self.uiHelpersDI = uiHelpersDI
    }
    
    // MARK: - WidgetObjectListModuleAssemblyProtocol
    
    func makeFavorites(bottomPanelManager: BrowserBottomPanelManagerProtocol, output: WidgetObjectListCommonModuleOutput?) -> UIViewController {
        let model = WidgetObjectListFavoritesViewModel(
            favoriteSubscriptionService: serviceLocator.favoriteSubscriptionService(),
            activeSpaceStorage: serviceLocator.activeSpaceStorage(),
            documentService: serviceLocator.documentService(),
            objectActionService: serviceLocator.objectActionsService()
        )
        return make(internalModel: model, bottomPanelManager: bottomPanelManager, output: output)
    }
    
    func makeRecent(bottomPanelManager: BrowserBottomPanelManagerProtocol, output: WidgetObjectListCommonModuleOutput?) -> UIViewController {
        let model = WidgetObjectListRecentViewModel(recentSubscriptionService: serviceLocator.recentSubscriptionService())
        return make(internalModel: model, bottomPanelManager: bottomPanelManager, output: output)
    }
    
    func makeSets(bottomPanelManager: BrowserBottomPanelManagerProtocol, output: WidgetObjectListCommonModuleOutput?) -> UIViewController {
        let model = WidgetObjectListSetsViewModel(setsSubscriptionService: serviceLocator.setsSubscriptionService())
        return make(internalModel: model, bottomPanelManager: bottomPanelManager, output: output)
    }
    
    func makeCollections(bottomPanelManager: BrowserBottomPanelManagerProtocol, output: WidgetObjectListCommonModuleOutput?) -> UIViewController {
        let model = WidgetObjectListCollectionsViewModel(subscriptionService: serviceLocator.collectionsSubscriptionService())
        return make(internalModel: model, bottomPanelManager: bottomPanelManager, output: output)
    }
    
    func makeBin(bottomPanelManager: BrowserBottomPanelManagerProtocol, output: WidgetObjectListCommonModuleOutput?) -> UIViewController {
        let model = WidgetObjectListBinViewModel(binSubscriptionService: serviceLocator.binSubscriptionService())
        return make(internalModel: model, bottomPanelManager: bottomPanelManager, output: output)
    }
    
    func makeFiles() -> UIViewController {
        let model = WidgetObjectListFilesViewModel(subscriptionService: serviceLocator.filesSubscriptionManager())
        return make(internalModel: model, bottomPanelManager: nil, output: nil, isSheet: true)
    }
    
    // MARK: - Private
    
    private func make(
        internalModel: WidgetObjectListInternalViewModelProtocol,
        bottomPanelManager: BrowserBottomPanelManagerProtocol?,
        output: WidgetObjectListCommonModuleOutput?,
        isSheet: Bool = false
    ) -> UIViewController {
        
        let model = WidgetObjectListViewModel(
            internalModel: internalModel,
            bottomPanelManager: bottomPanelManager,
            objectActionService: serviceLocator.objectActionsService(),
            menuBuilder: WidgetObjectListMenuBuilder(),
            alertOpener: uiHelpersDI.alertOpener(),
            output: output,
            isSheet: isSheet
        )
        let view = WidgetObjectListView(model: model)
        return WidgetObjectListHostingController(model: model, rootView: view)
    }
}
