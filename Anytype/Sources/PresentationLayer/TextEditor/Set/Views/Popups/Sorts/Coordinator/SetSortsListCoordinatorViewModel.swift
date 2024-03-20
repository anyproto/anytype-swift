import SwiftUI
import Services

@MainActor
protocol SetSortsListCoordinatorOutput: AnyObject {
    func onAddButtonTap(relationDetails: [RelationDetails], completion: @escaping (RelationDetails) -> Void)
    func onSetSortTap(_ setSort: SetSort, completion: @escaping (SetSort) -> Void)
}

@MainActor
final class SetSortsListCoordinatorViewModel: ObservableObject, SetSortsListCoordinatorOutput {
    @Published var sortsSearchData: SortsSearchData?
    @Published var sortTypesData: SetSortTypesData?
    
    let setDocument: SetDocumentProtocol
    let viewId: String
    private let newSearchModuleAssembly: NewSearchModuleAssemblyProtocol
    
    init(
        setDocument: SetDocumentProtocol,
        viewId: String,
        newSearchModuleAssembly: NewSearchModuleAssemblyProtocol
    ) {
        self.setDocument = setDocument
        self.viewId = viewId
        self.newSearchModuleAssembly = newSearchModuleAssembly
    }
    
    // MARK: - SetSortsListCoordinatorOutput
    
    // MARK: - Sorts search
    
    func onAddButtonTap(relationDetails: [RelationDetails], completion: @escaping (RelationDetails) -> Void) {
        sortsSearchData = SortsSearchData(
            relationDetails: relationDetails,
            completion: { [weak self] details in
                completion(details)
                self?.sortsSearchData = nil
            }
        )
    }
    
    func setSortsSearch(data: SortsSearchData) -> NewSearchView {
        newSearchModuleAssembly.setSortsSearchModule(
            relationsDetails: data.relationDetails,
            onSelect: data.completion
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

extension SetSortsListCoordinatorViewModel {
    
    struct SortsSearchData: Identifiable {
        let id = UUID()
        let relationDetails: [RelationDetails]
        let completion: (RelationDetails) -> Void
    }
}
