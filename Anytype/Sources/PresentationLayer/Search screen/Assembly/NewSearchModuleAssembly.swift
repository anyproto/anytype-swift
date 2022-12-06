import Foundation
import BlocksModels

final class NewSearchModuleAssembly: NewSearchModuleAssemblyProtocol {
 
    static func statusSearchModule(
        style: NewSearchView.Style = .default,
        selectionMode: NewSearchViewModel.SelectionMode = .singleItem,
        relationKey: String,
        selectedStatusesIds: [String],
        onSelect: @escaping (_ ids: [String]) -> Void,
        onCreate: @escaping (_ title: String) -> Void
    ) -> NewSearchView {
        let interactor = StatusSearchInteractor(
            relationKey: relationKey,
            selectedStatusesIds: selectedStatusesIds,
            isPreselectModeAvailable: selectionMode.isPreselectModeAvailable
        )
        
        let internalViewModel = StatusSearchViewModel(
            selectionMode: selectionMode,
            interactor: interactor,
            onSelect: onSelect
        )
        
        let viewModel = NewSearchViewModel(
            style: style,
            itemCreationMode: style.isCreationModeAvailable ? .available(action: onCreate) : .unavailable,
            selectionMode: selectionMode,
            internalViewModel: internalViewModel
        )
        return NewSearchView(viewModel: viewModel)
    }
    
    static func tagsSearchModule(
        style: NewSearchView.Style = .default,
        selectionMode: NewSearchViewModel.SelectionMode = .multipleItems(),
        relationKey: String,
        selectedTagIds: [String],
        onSelect: @escaping (_ ids: [String]) -> Void,
        onCreate: @escaping (_ title: String) -> Void
    ) -> NewSearchView {
        let interactor = TagsSearchInteractor(
            relationKey: relationKey,
            selectedTagIds: selectedTagIds,
            isPreselectModeAvailable: selectionMode.isPreselectModeAvailable
        )
        
        let internalViewModel = TagsSearchViewModel(
            selectionMode: selectionMode,
            interactor: interactor,
            onSelect: onSelect
        )
        
        let viewModel = NewSearchViewModel(
            style: style,
            itemCreationMode: style.isCreationModeAvailable ? .available(action: onCreate) : .unavailable,
            selectionMode: selectionMode,
            internalViewModel: internalViewModel
        )
        return NewSearchView(viewModel: viewModel)
    }
    
    static func objectsSearchModule(
        style: NewSearchView.Style = .default,
        selectionMode: NewSearchViewModel.SelectionMode = .multipleItems(),
        excludedObjectIds: [String],
        limitedObjectType: [String],
        onSelect: @escaping (_ ids: [String]) -> Void
    ) -> NewSearchView {
        let interactor = ObjectsSearchInteractor(
            searchService: ServiceLocator.shared.searchService(),
            excludedObjectIds: excludedObjectIds,
            limitedObjectType: limitedObjectType
        )
        
        let internalViewModel = ObjectsSearchViewModel(
            selectionMode: selectionMode,
            interactor: interactor,
            onSelect: { onSelect($0.map { $0.id })}
        )
        
        let viewModel = NewSearchViewModel(
            style: style,
            itemCreationMode: .unavailable,
            selectionMode: selectionMode,
            internalViewModel: internalViewModel
        )
        return NewSearchView(viewModel: viewModel)
    }
    
    static func filesSearchModule(
        style: NewSearchView.Style = .default,
        excludedFileIds: [String],
        onSelect: @escaping (_ ids: [String]) -> Void
    ) -> NewSearchView {
        let interactor = FilesSearchInteractor(
            searchService: ServiceLocator.shared.searchService(),
            excludedFileIds: excludedFileIds
        )
        
        let internalViewModel = ObjectsSearchViewModel(
            selectionMode: .multipleItems(),
            interactor: interactor,
            onSelect: { onSelect($0.map { $0.id })}
        )
        
        let viewModel = NewSearchViewModel(
            style: style,
            itemCreationMode: .unavailable,
            internalViewModel: internalViewModel
        )
        return NewSearchView(viewModel: viewModel)
    }
    
    static func objectTypeSearchModule(
        style: NewSearchView.Style = .default,
        title: String,
        selectedObjectId: BlockId? = nil,
        excludedObjectTypeId: String? = nil,
        showBookmark: Bool = false,
        showSet: Bool = false,
        onSelect: @escaping (_ id: String) -> Void
    ) -> NewSearchView {
        let interactor = ObjectTypesSearchInteractor(
            searchService: ServiceLocator.shared.searchService(),
            workspaceService: ServiceLocator.shared.workspaceService(),
            excludedObjectTypeId: excludedObjectTypeId,
            showBookmark: showBookmark,
            showSet: showSet
        )
        
        let internalViewModel = ObjectTypesSearchViewModel(
            interactor: interactor,
            selectedObjectId: selectedObjectId,
            onSelect: { ids in
                guard let id = ids.first else { return }
                onSelect(id)
            }
        )
        let viewModel = NewSearchViewModel(
            title: title,
            searchPlaceholder: Loc.ObjectType.searchOrInstall,
            style: style,
            itemCreationMode: .unavailable,
            internalViewModel: internalViewModel
        )
        
        return NewSearchView(viewModel: viewModel)
    }
    
    static func multiselectObjectTypesSearchModule(
        style: NewSearchView.Style = .default,
        selectedObjectTypeIds: [String],
        onSelect: @escaping (_ ids: [String]) -> Void
    ) -> NewSearchView {
        let interactor = ObjectTypesSearchInteractor(
            searchService: ServiceLocator.shared.searchService(),
            workspaceService: ServiceLocator.shared.workspaceService(),
            excludedObjectTypeId: nil,
            showBookmark: false,
            showSet: false
        )
        
        let internalViewModel = MultiselectObjectTypesSearchViewModel(
            selectedObjectTypeIds: selectedObjectTypeIds,
            interactor: interactor,
            onSelect: onSelect
        )
        
        let viewModel = NewSearchViewModel(
            title: Loc.limitObjectTypes,
            style: style,
            itemCreationMode: .unavailable,
            internalViewModel: internalViewModel
        )
        
        return NewSearchView(viewModel: viewModel)
    }
    
    static func blockObjectsSearchModule(
        style: NewSearchView.Style = .default,
        title: String,
        excludedObjectIds: [String],
        onSelect: @escaping (_ details: ObjectDetails) -> Void
    ) -> NewSearchView {
        let interactor = BlockObjectsSearchInteractor(
            searchService: ServiceLocator.shared.searchService(),
            excludedObjectIds: excludedObjectIds
        )

        let internalViewModel = ObjectsSearchViewModel(
            selectionMode: .singleItem,
            interactor: interactor,
            onSelect: { details in
                guard let result = details.first else { return }
                onSelect(result)
            }
        )
        let viewModel = NewSearchViewModel(
            title: title,
            style: style,
            itemCreationMode: .unavailable,
            internalViewModel: internalViewModel
        )

        return NewSearchView(viewModel: viewModel)
    }
    
    static func setSortsSearchModule(
        style: NewSearchView.Style = .default,
        relationsDetails: [RelationDetails],
        onSelect: @escaping (_ relation: RelationDetails) -> Void
    ) -> NewSearchView {
        let interactor = SetSortsSearchInteractor(relationsDetails: relationsDetails)
        
        let internalViewModel = SetSortsSearchViewModel(
            interactor: interactor,
            onSelect: { details in
                guard let result = details.first else { return }
                onSelect(result)
            }
        )
        
        let viewModel = NewSearchViewModel(
            searchPlaceholder: Loc.EditSet.Popup.Sort.Add.searchPlaceholder,
            style: style,
            itemCreationMode: .unavailable,
            internalViewModel: internalViewModel
        )
        
        return NewSearchView(viewModel: viewModel)
    }
}
