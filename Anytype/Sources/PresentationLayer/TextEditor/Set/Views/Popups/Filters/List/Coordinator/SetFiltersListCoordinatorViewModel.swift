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
    @Published var filtersSearchData: SetRelationsDetailsLocalSearchData?
    
    let data: SetFiltersListModuleData
    let subscriptionDetailsStorage: ObjectDetailsStorage
    private let setFiltersSelectionCoordinatorAssembly: SetFiltersSelectionCoordinatorAssemblyProtocol
    private let newSearchModuleAssembly: NewSearchModuleAssemblyProtocol
    
    init(
        setDocument: SetDocumentProtocol,
        viewId: String,
        subscriptionDetailsStorage: ObjectDetailsStorage,
        setFiltersSelectionCoordinatorAssembly: SetFiltersSelectionCoordinatorAssemblyProtocol,
        newSearchModuleAssembly: NewSearchModuleAssemblyProtocol
    ) {
        self.data = SetFiltersListModuleData(setDocument: setDocument, viewId: viewId)
        self.subscriptionDetailsStorage = subscriptionDetailsStorage
        self.setFiltersSelectionCoordinatorAssembly = setFiltersSelectionCoordinatorAssembly
        self.newSearchModuleAssembly = newSearchModuleAssembly
    }
    
    // MARK: - SetFiltersListCoordinatorOutput
    
    // MARK: - Filters search
    func onAddButtonTap(relationDetails: [RelationDetails], completion: @escaping (RelationDetails) -> Void) {
        filtersSearchData = SetRelationsDetailsLocalSearchData(
            relationsDetails: relationDetails,
            onSelect: completion
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
            with: self.data.setDocument.spaceId,
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
}
