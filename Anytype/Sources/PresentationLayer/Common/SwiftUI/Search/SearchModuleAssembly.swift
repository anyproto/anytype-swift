import Foundation
import Services
import SwiftUI

@MainActor
final class SearchModuleAssembly: SearchModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    nonisolated init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - SearchModuleAssemblyProtocol
    
    func makeSpaceSearch(
        data: SearchSpaceModel
    ) -> AnyView {
        let viewModel = SpaceSearchViewModel(
            workspacesStorage: serviceLocator.workspaceStorage(),
            onSelect: data.onSelect
        )
        let view = SearchView(title: Loc.Spaces.Search.title, viewModel: viewModel)
        return view.eraseToAnyView()
    }
    
    func makeObjectSearch(
        data: SearchModuleModel
    ) -> AnyView {
        if data.layoutLimits.isNotEmpty {
            return makeObjectSearch(title: data.title, spaceId: data.spaceId, layouts: data.layoutLimits, onSelect: data.onSelect)
        } else {
            return makeObjectSearch(title: data.title, spaceId: data.spaceId, onSelect: data.onSelect)
        }
    }
    
    // MARK: - Private
    
    private func makeObjectSearch(
        title: String?,
        spaceId: String,
        onSelect: @escaping (ObjectSearchData) -> ()
    ) -> AnyView {
        let viewModel = ObjectSearchViewModel(
            spaceId: spaceId,
            searchService: WrappedSearchInteractor(searchService: serviceLocator.searchService())
        ) { data in
            onSelect(data)
        }
        let searchView = SearchView(title: title, viewModel: viewModel)
        return searchView.eraseToAnyView()
    }
    
    private func makeObjectSearch(
        title: String?,
        spaceId: String,
        layouts: [DetailsLayout],
        onSelect: @escaping (ObjectSearchData) -> ()
    ) -> AnyView {
        let viewModel = ObjectSearchViewModel(
            spaceId: spaceId,
            searchService: ObjectLayoutSearch(
                layouts: layouts,
                searchService: serviceLocator.searchService()
            ), onSelect: { data in
                onSelect(data)
            }
        )
        let searchView = SearchView(title: title, viewModel: viewModel)
        return searchView.eraseToAnyView()
    }
}
