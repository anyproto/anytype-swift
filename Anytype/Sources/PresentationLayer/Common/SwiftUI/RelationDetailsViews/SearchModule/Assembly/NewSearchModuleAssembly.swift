import Foundation

final class NewSearchModuleAssembly {
 
    static func buildStatusSearchModule(allStatuses: [Relation.Status.Option], selectedStatus: Relation.Status.Option?) -> NewSearchView {
        let interactor = StatusSearchInteractor(
            allStatuses: allStatuses,
            selectedStatus: selectedStatus
        )
        
        let viewModel = StatusSearchViewModel(interactor: interactor)
        return NewSearchView(viewModel: NewSearchViewModel(internalViewModel: viewModel))
    }
    
    static func buildTagsSearchModule(allTags: [Relation.Tag.Option], selectedTagIds: [String]) -> NewSearchView {
        let interactor = TagsSearchInteractor(
            allTags: allTags,
            selectedTagIds: selectedTagIds
        )
        
        let viewModel = TagsSearchViewModel(interactor: interactor)
        return NewSearchView(viewModel: NewSearchViewModel(internalViewModel: viewModel))
    }
    
    static func buildObjectsSearchModule(selectedObjectIds: [String]) -> NewSearchView {
        let interactor = ObjectsSearchInteractor(
            searchService: SearchService(),
            selectedObjectIds: selectedObjectIds
        )
        
        let viewModel = ObjectsSearchViewModel(interactor: interactor)
        return NewSearchView(viewModel: NewSearchViewModel(internalViewModel: viewModel))
    }
    
    static func buildFilesSearchModule(selectedObjectIds: [String]) -> NewSearchView {
        let interactor = FilesSearchInteractor(
            searchService: SearchService(),
            selectedObjectIds: selectedObjectIds
        )
        
        let viewModel = ObjectsSearchViewModel(interactor: interactor)
        return NewSearchView(viewModel: NewSearchViewModel(internalViewModel: viewModel))
    }
    
}
