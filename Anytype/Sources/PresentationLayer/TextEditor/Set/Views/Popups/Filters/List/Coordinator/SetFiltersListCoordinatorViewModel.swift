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
    @Published var filtersSearchData: SetPropertiesDetailsLocalSearchData?
    
    let data: SetFiltersListModuleData
    let subscriptionDetailsStorage: ObjectDetailsStorage
    
    init(
        setDocument: some SetDocumentProtocol,
        viewId: String,
        subscriptionDetailsStorage: ObjectDetailsStorage
    ) {
        self.data = SetFiltersListModuleData(setDocument: setDocument, viewId: viewId)
        self.subscriptionDetailsStorage = subscriptionDetailsStorage
    }
    
    // MARK: - SetFiltersListCoordinatorOutput
    
    // MARK: - Filters search
    func onAddButtonTap(relationDetails: [RelationDetails], completion: @escaping (RelationDetails) -> Void) {
        filtersSearchData = SetPropertiesDetailsLocalSearchData(
            relationsDetails: relationDetails,
            onSelect: completion
        )
    }
    
    // MARK: - Filters selection
    
    func onFilterTap(filter: SetFilter, completion: @escaping (SetFilter) -> Void) {
        filtersSelectionData = FiltersSelectionData(
            filter: filter,
            completion: { [weak self] filter in
                self?.filtersSelectionData = nil
                completion(filter)
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
