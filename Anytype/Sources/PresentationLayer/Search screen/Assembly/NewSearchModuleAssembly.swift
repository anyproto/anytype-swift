import Foundation
import BlocksModels

final class NewSearchModuleAssembly: NewSearchModuleAssemblyProtocol {
 
    private let uiHelpersDI: UIHelpersDIProtocol
    private let serviceLocator: ServiceLocator
    
    init(uiHelpersDI: UIHelpersDIProtocol, serviceLocator: ServiceLocator) {
        self.uiHelpersDI = uiHelpersDI
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - NewSearchModuleAssemblyProtocol
    
    func statusSearchModule(
        style: NewSearchView.Style,
        selectionMode: NewSearchViewModel.SelectionMode,
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
    
    func tagsSearchModule(
        style: NewSearchView.Style,
        selectionMode: NewSearchViewModel.SelectionMode,
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
    
    func objectsSearchModule(
        title: String?,
        style: NewSearchView.Style,
        selectionMode: NewSearchViewModel.SelectionMode,
        excludedObjectIds: [String],
        limitedObjectType: [String],
        onSelect: @escaping (_ ids: [String]) -> Void
    ) -> NewSearchView {
        let interactor = ObjectsSearchInteractor(
            searchService: serviceLocator.searchService(),
            excludedObjectIds: excludedObjectIds,
            limitedObjectType: limitedObjectType
        )
        
        let internalViewModel = ObjectsSearchViewModel(
            selectionMode: selectionMode,
            interactor: interactor,
            onSelect: { onSelect($0.map { $0.id })}
        )
        
        let viewModel = NewSearchViewModel(
            title: title,
            style: style,
            itemCreationMode: .unavailable,
            selectionMode: selectionMode,
            internalViewModel: internalViewModel
        )
        return NewSearchView(viewModel: viewModel)
    }
    
    func filesSearchModule(
        excludedFileIds: [String],
        onSelect: @escaping (_ ids: [String]) -> Void
    ) -> NewSearchView {
        let interactor = FilesSearchInteractor(
            searchService: serviceLocator.searchService(),
            excludedFileIds: excludedFileIds
        )
        
        let internalViewModel = ObjectsSearchViewModel(
            selectionMode: .multipleItems(),
            interactor: interactor,
            onSelect: { onSelect($0.map { $0.id })}
        )
        
        let viewModel = NewSearchViewModel(
            style: .default,
            itemCreationMode: .unavailable,
            internalViewModel: internalViewModel
        )
        return NewSearchView(viewModel: viewModel)
    }
    
    func objectTypeSearchModule(
        style: NewSearchView.Style,
        title: String,
        selectedObjectId: BlockId?,
        excludedObjectTypeId: String?,
        showBookmark: Bool,
        showSet: Bool,
        browser: EditorBrowserController?,
        onSelect: @escaping (_ type: ObjectType) -> Void
    ) -> NewSearchView {
        let interactor = ObjectTypesSearchInteractor(
            searchService: serviceLocator.searchService(),
            workspaceService: serviceLocator.workspaceService(),
            excludedObjectTypeId: excludedObjectTypeId,
            showBookmark: showBookmark,
            showSet: showSet
        )
        
        let internalViewModel = ObjectTypesSearchViewModel(
            interactor: interactor,
            toastPresenter: uiHelpersDI.toastPresenter(using: browser),
            selectedObjectId: selectedObjectId,
            onSelect: onSelect
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
    
    func multiselectObjectTypesSearchModule(
        selectedObjectTypeIds: [String],
        onSelect: @escaping (_ ids: [String]) -> Void
    ) -> NewSearchView {
        let interactor = ObjectTypesSearchInteractor(
            searchService: serviceLocator.searchService(),
            workspaceService: serviceLocator.workspaceService(),
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
            style: .default,
            itemCreationMode: .unavailable,
            internalViewModel: internalViewModel
        )
        
        return NewSearchView(viewModel: viewModel)
    }
    
    func blockObjectsSearchModule(
        title: String,
        excludedObjectIds: [String],
        onSelect: @escaping (_ details: ObjectDetails) -> Void
    ) -> NewSearchView {
        let interactor = BlockObjectsSearchInteractor(
            searchService: serviceLocator.searchService(),
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
            style: .default,
            itemCreationMode: .unavailable,
            internalViewModel: internalViewModel
        )

        return NewSearchView(viewModel: viewModel)
    }
    
    func setSortsSearchModule(
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
            style: .default,
            itemCreationMode: .unavailable,
            internalViewModel: internalViewModel
        )
        
        return NewSearchView(viewModel: viewModel)
    }
    
    func relationsSearchModule(
        document: BaseDocumentProtocol,
        output: RelationSearchModuleOutput
    ) -> NewSearchView {
        
        let interactor = RelationsSearchInteractor(
            searchService: serviceLocator.searchService(),
            workspaceService: serviceLocator.workspaceService(),
            relationsService: RelationsService(objectId: document.objectId)
        )
        
        let internalViewModel = RelationsSearchViewModel(
            selectedRelations: document.parsedRelations,
            interactor: interactor,
            toastPresenter: uiHelpersDI.toastPresenter(),
            onSelect: { result in
                output.didAddRelation(result)
            }
        )
        let viewModel = NewSearchViewModel(
            searchPlaceholder: "Search or create a new relation",
            style: .default,
            itemCreationMode: .available(action: { title in
                output.didAskToShowCreateNewRelation(searchText: title)
            }),
            internalViewModel: internalViewModel
        )
        
        return NewSearchView(viewModel: viewModel)
    }
}
