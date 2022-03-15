import Foundation

final class NewSearchModuleAssembly {
 
    static func buildStatusSearchModule(allStatuses: [Relation.Status.Option], selectedStatus: Relation.Status.Option?) -> NewSearchView {
        let interactor = StatusSearchInteractor(
            allStatuses: allStatuses,
            selectedStatus: selectedStatus
        )
        
        let internalViewModel = StatusSearchViewModel(interactor: interactor)
        let viewModel = NewSearchViewModel(selectionMode: .singleItem, internalViewModel: internalViewModel)
        return NewSearchView(viewModel: viewModel)
    }
    
    static func buildTagsSearchModule(allTags: [Relation.Tag.Option], selectedTagIds: [String]) -> NewSearchView {
        let interactor = TagsSearchInteractor(
            allTags: allTags,
            selectedTagIds: selectedTagIds
        )
        
        let internalViewModel = TagsSearchViewModel(interactor: interactor)
        let viewModel = NewSearchViewModel(selectionMode: .multipleItems, internalViewModel: internalViewModel)
        return NewSearchView(viewModel: viewModel)
    }
    
    static func buildObjectsSearchModule(selectedObjectIds: [String]) -> NewSearchView {
        let interactor = ObjectsSearchInteractor(
            searchService: SearchService(),
            selectedObjectIds: selectedObjectIds
        )
        
        let internalViewModel = ObjectsSearchViewModel(interactor: interactor)
        let viewModel = NewSearchViewModel(selectionMode: .multipleItems, internalViewModel: internalViewModel)
        return NewSearchView(viewModel: viewModel)
    }
    
    static func buildFilesSearchModule(selectedObjectIds: [String]) -> NewSearchView {
        let interactor = FilesSearchInteractor(
            searchService: SearchService(),
            selectedObjectIds: selectedObjectIds
        )
        
        let internalViewModel = ObjectsSearchViewModel(interactor: interactor)
        let viewModel = NewSearchViewModel(selectionMode: .multipleItems, internalViewModel: internalViewModel)
        return NewSearchView(viewModel: viewModel)
    }
    
}
