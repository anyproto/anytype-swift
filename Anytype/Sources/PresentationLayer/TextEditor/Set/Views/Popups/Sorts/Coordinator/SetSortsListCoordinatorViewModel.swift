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
    @Published var sortTypesData: SortTypesData?
    
    private let setDocument: SetDocumentProtocol
    private let viewId: String
    private let setSortsListModuleAssembly: SetSortsListModuleAssemblyProtocol
    private let newSearchModuleAssembly: NewSearchModuleAssemblyProtocol
    private let setSortTypesListModuleAssembly: SetSortTypesListModuleAssemblyProtocol
    
    init(
        setDocument: SetDocumentProtocol,
        viewId: String,
        setSortsListModuleAssembly: SetSortsListModuleAssemblyProtocol,
        newSearchModuleAssembly: NewSearchModuleAssemblyProtocol,
        setSortTypesListModuleAssembly: SetSortTypesListModuleAssemblyProtocol
    ) {
        self.setDocument = setDocument
        self.viewId = viewId
        self.setSortsListModuleAssembly = setSortsListModuleAssembly
        self.newSearchModuleAssembly = newSearchModuleAssembly
        self.setSortTypesListModuleAssembly = setSortTypesListModuleAssembly
    }
    
    func list() -> AnyView {
        setSortsListModuleAssembly.make(
            with: setDocument,
            viewId: viewId,
            output: self
        )
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
        sortTypesData = SortTypesData(
            setSort: setSort,
            completion: { [weak self] setSort in
                completion(setSort)
                self?.sortTypesData = nil
            }
        )
    }

    func setSortTypesList(data: SortTypesData) -> AnyView {
        setSortTypesListModuleAssembly.make(
            with: data.setSort,
            completion: data.completion
        )
    }
}

extension SetSortsListCoordinatorViewModel {
    
    struct SortsSearchData: Identifiable {
        let id = UUID()
        let relationDetails: [RelationDetails]
        let completion: (RelationDetails) -> Void
    }
    
    struct SortTypesData: Identifiable {
        var id: String { setSort.id }
        let setSort: SetSort
        let completion: (SetSort) -> Void
    }
}
