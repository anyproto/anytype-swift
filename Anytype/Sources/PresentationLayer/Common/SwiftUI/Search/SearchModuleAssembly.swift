import Foundation
import SwiftUI

final class SearchModuleAssembly: SearchModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - SearchModuleAssemblyProtocol
    
    func makeObjectSearch(data: SearchModuleModel) -> AnyView {
        let searchView = SearchView(
            title: data.title,
            viewModel: ObjectSearchViewModel(
                spaceId: data.spaceId,
                searchService: self.serviceLocator.searchService()
            ) { result in
                data.onSelect(result)
            }
        )
        return searchView.eraseToAnyView()
    }
}
