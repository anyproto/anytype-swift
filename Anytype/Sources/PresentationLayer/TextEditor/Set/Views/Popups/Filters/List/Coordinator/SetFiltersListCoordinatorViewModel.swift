import SwiftUI
import Services

@MainActor
protocol SetFiltersListCoordinatorOutput: AnyObject {
    func onAddButtonTap(relationDetails: [RelationDetails], completion: @escaping (RelationDetails) -> Void)
    func onFilterTap(filter: SetFilter, completion: @escaping (SetFilter) -> Void)
}

@MainActor
final class SetFiltersListCoordinatorViewModel: ObservableObject, SetFiltersListCoordinatorOutput {
    @Published var filtersSelectionData: FiltersSelectionData?
    @Published var filtersSearchData: FiltersSearchData?
    
    private let setDocument: SetDocumentProtocol
    private let viewId: String
    private let subscriptionDetailsStorage: ObjectDetailsStorage
    private let setFiltersListModuleAssembly: SetFiltersListModuleAssemblyProtocol
    private let setFiltersSelectionCoordinatorAssembly: SetFiltersSelectionCoordinatorAssemblyProtocol
    private let newSearchModuleAssembly: NewSearchModuleAssemblyProtocol
    
    init(
        setDocument: SetDocumentProtocol,
        viewId: String,
        subscriptionDetailsStorage: ObjectDetailsStorage,
        setFiltersListModuleAssembly: SetFiltersListModuleAssemblyProtocol,
        setFiltersSelectionCoordinatorAssembly: SetFiltersSelectionCoordinatorAssemblyProtocol,
        newSearchModuleAssembly: NewSearchModuleAssemblyProtocol
    ) {
        self.setDocument = setDocument
        self.viewId = viewId
        self.subscriptionDetailsStorage = subscriptionDetailsStorage
        self.setFiltersListModuleAssembly = setFiltersListModuleAssembly
        self.setFiltersSelectionCoordinatorAssembly = setFiltersSelectionCoordinatorAssembly
        self.newSearchModuleAssembly = newSearchModuleAssembly
    }
    
    func list() -> AnyView {
        setFiltersListModuleAssembly.make(
            with: setDocument,
            viewId: viewId,
            subscriptionDetailsStorage: subscriptionDetailsStorage,
            output: self
        )
    }
    
    // MARK: - SetFiltersListCoordinatorOutput
    
    // MARK: - Filters search
    func onAddButtonTap(relationDetails: [RelationDetails], completion: @escaping (RelationDetails) -> Void) {
        filtersSearchData = FiltersSearchData(
            relationDetails: relationDetails,
            completion: completion
        )
    }
    
    func setFiltersSearch(data: FiltersSearchData) -> NewSearchView {
        newSearchModuleAssembly.setSortsSearchModule(
            relationsDetails: data.relationDetails,
            onSelect: { [weak self] relationDetails in
                self?.filtersSearchData = nil
                data.completion(relationDetails)
            }
        )
    }
    
    // MARK: - Filters selection
    
    func onFilterTap(filter: SetFilter, completion: @escaping (SetFilter) -> Void) {
        filtersSelectionData = FiltersSelectionData(
            filter: filter,
            completion: completion
        )
    }
    
    func setFiltersSelection(data: FiltersSelectionData) -> AnyView {
        setFiltersSelectionCoordinatorAssembly.make(
            with: setDocument.spaceId,
            filter: data.filter,
            completion: { [weak self] filter in
                self?.filtersSelectionData = nil
                data.completion(filter)
            }
        )
    }
}

extension SetFiltersListCoordinatorViewModel {
    struct FiltersSelectionData: Identifiable {
        let filter: SetFilter
        let completion: (SetFilter) -> Void
        
        var id: String { filter.id }
    }
    
    struct FiltersSearchData: Identifiable {
        let id = UUID()
        let relationDetails: [RelationDetails]
        let completion: (RelationDetails) -> Void
    }
}
