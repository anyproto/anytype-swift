import Foundation

final class NewSearchModuleAssembly {
 
    static func buildStatusSearchModule(allStatuses: [Relation.Status.Option], selectedStatus: Relation.Status.Option?, onSelect: @escaping (_ ids: [String]) -> Void) -> NewSearchView {
        let interactor = StatusSearchInteractor(
            allStatuses: allStatuses,
            selectedStatus: selectedStatus
        )
        
        let internalViewModel = StatusSearchViewModel(interactor: interactor)
        let viewModel = NewSearchViewModel(
            selectionMode: .singleItem,
            itemCreationMode: .unavailable,
            internalViewModel: internalViewModel,
            onSelect: onSelect
        )
        return NewSearchView(viewModel: viewModel)
    }
    
    static func buildTagsSearchModule(allTags: [Relation.Tag.Option], selectedTagIds: [String], onSelect: @escaping (_ ids: [String]) -> Void) -> NewSearchView {
        let interactor = TagsSearchInteractor(
            allTags: allTags,
            selectedTagIds: selectedTagIds
        )
        
        let internalViewModel = TagsSearchViewModel(interactor: interactor)
        let viewModel = NewSearchViewModel(
            selectionMode: .multipleItems,
            itemCreationMode: .unavailable,
            internalViewModel: internalViewModel,
            onSelect: onSelect
        )
        return NewSearchView(viewModel: viewModel)
    }
    
    static func buildObjectsSearchModule(selectedObjectIds: [String], onSelect: @escaping (_ ids: [String]) -> Void) -> NewSearchView {
        let interactor = ObjectsSearchInteractor(
            searchService: SearchService(),
            selectedObjectIds: selectedObjectIds
        )
        
        let internalViewModel = ObjectsSearchViewModel(interactor: interactor)
        let viewModel = NewSearchViewModel(
            selectionMode: .multipleItems,
            itemCreationMode: .unavailable,
            internalViewModel: internalViewModel,
            onSelect: onSelect
        )
        return NewSearchView(viewModel: viewModel)
    }
    
    static func buildFilesSearchModule(selectedObjectIds: [String], onSelect: @escaping (_ ids: [String]) -> Void) -> NewSearchView {
        let interactor = FilesSearchInteractor(
            searchService: SearchService(),
            selectedObjectIds: selectedObjectIds
        )
        
        let internalViewModel = ObjectsSearchViewModel(interactor: interactor)
        let viewModel = NewSearchViewModel(
            selectionMode: .multipleItems,
            itemCreationMode: .unavailable,
            internalViewModel: internalViewModel,
            onSelect: onSelect
        )
        return NewSearchView(viewModel: viewModel)
    }
    
}
