import SwiftUI
import Services

@MainActor
protocol SetSortsListCoordinatorOutput: AnyObject {
    func onAddButtonTap(relationDetails: [RelationDetails], completion: @escaping (RelationDetails) -> Void)
    func onSetSortTap(_ setSort: SetSort, completion: @escaping (SetSort) -> Void)
}

@MainActor
final class SetSortsListCoordinatorViewModel: ObservableObject, SetSortsListCoordinatorOutput {
    @Published var sortsSearchData: SetRelationsDetailsLocalSearchData?
    @Published var sortTypesData: SetSortTypesData?
    
    let setDocument: SetDocumentProtocol
    let viewId: String
    
    init(
        setDocument: SetDocumentProtocol,
        viewId: String
    ) {
        self.setDocument = setDocument
        self.viewId = viewId
    }
    
    // MARK: - SetSortsListCoordinatorOutput
    
    // MARK: - Sorts search
    
    func onAddButtonTap(relationDetails: [RelationDetails], completion: @escaping (RelationDetails) -> Void) {
        sortsSearchData = SetRelationsDetailsLocalSearchData(
            relationsDetails: relationDetails,
            onSelect: completion
        )
    }
    
    // MARK: - Sort types
    
    func onSetSortTap(_ setSort: SetSort, completion: @escaping (SetSort) -> Void) {
        sortTypesData = SetSortTypesData(
            setSort: setSort,
            completion: { [weak self] setSort in
                completion(setSort)
                self?.sortTypesData = nil
            }
        )
    }
}
