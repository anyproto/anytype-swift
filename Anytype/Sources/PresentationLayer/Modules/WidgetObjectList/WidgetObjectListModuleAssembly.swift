import Foundation
import SwiftUI

protocol WidgetObjectListModuleAssemblyProtocol: AnyObject {
    func makeFavorites(output: WidgetObjectListCommonModuleOutput?) -> UIViewController
    func makeRecent() -> UIViewController
    func makeSets(output: WidgetObjectListCommonModuleOutput?) -> UIViewController
    func makeBin() -> UIViewController
}

final class WidgetObjectListModuleAssembly: WidgetObjectListModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - WidgetObjectListModuleAssemblyProtocol
    
    func makeFavorites(output: WidgetObjectListCommonModuleOutput?) -> UIViewController {
        let model = WidgetObjectListFavoriesViewModel(
            favoriteSubscriptionService: serviceLocator.favoriteSubscriptionService(),
            accountManager: serviceLocator.accountManager(),
            documentService: serviceLocator.documentService()
        )
        return make(internalModel: model, output: output)
    }
    
    func makeRecent() -> UIViewController {
        let model = WidgetObjectListRecentViewModel(
            recentSubscriptionService: serviceLocator.recentSubscriptionService()
        )
        return make(internalModel: model, output: nil)
    }
    
    func makeSets(output: WidgetObjectListCommonModuleOutput?) -> UIViewController {
        let model = WidgetObjectListSetsViewModel(
            setsSubscriptionService: serviceLocator.setsSubscriptionService()
        )
        return make(internalModel: model, output: output)
    }
    
    func makeBin() -> UIViewController {
        let model = WidgetObjectListEmptyViewModel()
        return make(internalModel: model, output: nil)
    }
    
    // MARK: - Private
    
    private func make(internalModel: WidgetObjectListInternalViewModelProtocol, output: WidgetObjectListCommonModuleOutput?) -> UIViewController {
        let model = WidgetObjectListViewModel(internalModel: internalModel, output: output)
        let view = WidgetObjectListView(model: model)
        return WidgetObjectListHostingController(model: model, rootView: view)
    }
}
