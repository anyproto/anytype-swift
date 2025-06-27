import SwiftUI
import Services

@MainActor
protocol SetSortsListCoordinatorOutput: AnyObject {
    func onAddButtonTap(relationDetails: [PropertyDetails], completion: @escaping (PropertyDetails) -> Void)
    func onSetSortTap(_ setSort: SetSort, completion: @escaping (SetSort, String) -> Void)
}

@MainActor
final class SetSortsListCoordinatorViewModel: ObservableObject, SetSortsListCoordinatorOutput {
    @Published var sortsSearchData: SetPropertiesDetailsLocalSearchData?
    @Published var sortTypesData: SetSortTypesData?
    
    let setDocument: any SetDocumentProtocol
    let viewId: String
    
    init(
        setDocument: some SetDocumentProtocol,
        viewId: String
    ) {
        self.setDocument = setDocument
        self.viewId = viewId
    }
    
    // MARK: - SetSortsListCoordinatorOutput
    
    // MARK: - Sorts search
    
    func onAddButtonTap(relationDetails: [PropertyDetails], completion: @escaping (PropertyDetails) -> Void) {
        sortsSearchData = SetPropertiesDetailsLocalSearchData(
            relationsDetails: relationDetails,
            onSelect: completion
        )
    }
    
    // MARK: - Sort types
    
    func onSetSortTap(_ setSort: SetSort, completion: @escaping (SetSort, String) -> Void) {
        sortTypesData = SetSortTypesData(
            setSort: setSort,
            completion: { [weak self] setSort, type in
                completion(setSort, type)
                self?.sortTypesData = nil
            }
        )
    }
}
