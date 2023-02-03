import Foundation
import SwiftUI

protocol WidgetObjectListModuleAssemblyProtocol: AnyObject {
    func makeFavorites() -> UIViewController
    func makeRecent() -> UIViewController
    func makeSets() -> UIViewController
    func makeBin() -> UIViewController
}

final class WidgetObjectListModuleAssembly: WidgetObjectListModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - WidgetObjectListModuleAssemblyProtocol
    
    func makeFavorites() -> UIViewController {
        let model = WidgetObjectListFavoriesViewModel(
            favoriteSubscriptionService: serviceLocator.favoriteSubscriptionService(),
            accountManager: serviceLocator.accountManager(),
            documentService: serviceLocator.documentService()
        )
        return make(model: model)
    }
    
    func makeRecent() -> UIViewController {
        let model = WidgetObjectListEmptyViewModel()
        return make(model: model)
    }
    
    func makeSets() -> UIViewController {
        let model = WidgetObjectListEmptyViewModel()
        return make(model: model)
    }
    
    func makeBin() -> UIViewController {
        let model = WidgetObjectListEmptyViewModel()
        return make(model: model)
    }
    
    // MARK: - Private
    
    private func make<Model: WidgetObjectListViewModelProtocol>(model: Model) -> UIViewController {
        let view = WidgetObjectListView(model: model)
        return WidgetObjectListHostingController(model: model, rootView: view)
    }
}
