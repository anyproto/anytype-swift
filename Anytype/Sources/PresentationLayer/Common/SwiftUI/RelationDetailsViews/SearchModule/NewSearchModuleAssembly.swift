import Foundation

final class NewSearchModuleAssembly {
 
    static func buildStatusSearchModule(allStatuses: [Relation.Status.Option], selectedStatus: Relation.Status.Option?) -> NewSearchView {
        let interactor = StatusSearchInteractor(
            allStatuses: allStatuses,
            selectedStatus: selectedStatus
        )
        
        let viewModel = StatusSearchViewModel(interactor: interactor)
        return NewSearchView(viewModel: viewModel)
    }
    
}
