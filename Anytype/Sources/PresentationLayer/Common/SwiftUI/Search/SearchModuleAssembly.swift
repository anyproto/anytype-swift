import Foundation
import UIKit

final class SearchModuleAssembly: SearchModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - SearchModuleAssemblyProtocol
    
    func makeObjectSearch(
        spaceId: String,
        title: String?,
        onSelect: @escaping (ObjectSearchData) -> ()
    ) -> SwiftUIModule {
        let viewModel = ObjectSearchViewModel(spaceId: spaceId, searchService: serviceLocator.searchService()) { data in
            onSelect(data)
        }
        let searchView = SearchView(title: title, viewModel: viewModel)
        return SwiftUIModule(view: searchView, model: viewModel)
    }
}
