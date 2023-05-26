import Foundation
import UIKit

final class SearchModuleAssembly: SearchModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - SearchModuleAssemblyProtocol
    
    func makeObjectSearch(
        title: String?,
        onSelect: @escaping (ObjectSearchData) -> ()
    ) -> SwiftUIModule {
        let viewModel = ObjectSearchViewModel(searchService: serviceLocator.searchService()) { data in
            onSelect(data)
        }
        let searchView = SearchView(title: title, viewModel: viewModel)
        return SwiftUIModule(view: searchView, model: viewModel)
    }
}
