import Foundation
import Services
import SwiftUI

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
        spaceId: String,
        relationKey: String,
        selectedStatusesIds: [String],
        onSelect: @escaping (_ ids: [String]) -> Void,
        onCreate: @escaping (_ title: String) -> Void
    ) -> NewSearchView {
        let interactor = StatusSearchInteractor(
            spaceId: spaceId,
            relationKey: relationKey,
            selectedStatusesIds: selectedStatusesIds,
            isPreselectModeAvailable: selectionMode.isPreselectModeAvailable,
            searchService: serviceLocator.searchService()
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
        spaceId: String,
        relationKey: String,
        selectedTagIds: [String],
        onSelect: @escaping (_ ids: [String]) -> Void,
        onCreate: @escaping (_ title: String) -> Void
    ) -> NewSearchView {
        let interactor = TagsSearchInteractor(
            spaceId: spaceId,
            relationKey: relationKey,
            selectedTagIds: selectedTagIds,
            isPreselectModeAvailable: selectionMode.isPreselectModeAvailable,
            searchService: serviceLocator.searchService()
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
        spaceId: String,
        style: NewSearchView.Style,
        selectionMode: NewSearchViewModel.SelectionMode,
        excludedObjectIds: [String],
        limitedObjectType: [String],
        onSelect: @escaping (_ details: [ObjectDetails]) -> Void
    ) -> NewSearchView {
        let interactor = ObjectsSearchInteractor(
            spaceId: spaceId,
            searchService: serviceLocator.searchService(),
            excludedObjectIds: excludedObjectIds,
            limitedObjectType: limitedObjectType
        )
        
        let internalViewModel = ObjectsSearchViewModel(
            selectionMode: selectionMode,
            interactor: interactor,
            onSelect: { onSelect($0)}
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
        spaceId: String,
        excludedFileIds: [String],
        onSelect: @escaping (_ ids: [String]) -> Void
    ) -> NewSearchView {
        let interactor = FilesSearchInteractor(
            spaceId: spaceId,
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
        spaceId: String,
        selectedObjectId: String?,
        showSetAndCollection: Bool,
        showFiles: Bool,
        onSelect: @escaping (_ type: ObjectType) -> Void
    ) -> NewSearchView {
        let interactor = Legacy_ObjectTypeSearchInteractor(
            spaceId: spaceId,
            typesService: serviceLocator.typesService(),
            workspaceService: serviceLocator.workspaceService(),
            objectTypeProvider: serviceLocator.objectTypeProvider(),
            showBookmark: true,
            showSetAndCollection: showSetAndCollection, 
            showFiles: showFiles
        )
        
        let internalViewModel = Legacy_ObjectTypeSearchViewModel(
            interactor: interactor,
            toastPresenter: uiHelpersDI.toastPresenter(),
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
        spaceId: String,
        onSelect: @escaping (_ ids: [String]) -> Void
    ) -> NewSearchView {
        let interactor = Legacy_ObjectTypeSearchInteractor(
            spaceId: spaceId,
            typesService: serviceLocator.typesService(),
            workspaceService: serviceLocator.workspaceService(),
            objectTypeProvider: serviceLocator.objectTypeProvider(),
            showBookmark: true,
            showSetAndCollection: false, 
            showFiles: false
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
        spaceId: String,
        excludedObjectIds: [String],
        excludedLayouts: [DetailsLayout],
        onSelect: @escaping (_ details: ObjectDetails) -> Void
    ) -> NewSearchView {
        let interactor = BlockObjectsSearchInteractor(
            spaceId: spaceId,
            excludedObjectIds: excludedObjectIds,
            excludedLayouts: excludedLayouts,
            searchService: serviceLocator.searchService()
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
        excludedRelationsIds: [String],
        target: RelationsModuleTarget,
        output: RelationSearchModuleOutput
    ) -> NewSearchView {
        
        let relationsInteractor = RelationsInteractor(
            objectId: document.objectId,
            relationsService: serviceLocator.relationService(),
            dataviewService: serviceLocator.dataviewService()
        )
        let interactor = RelationsSearchInteractor(
            searchService: serviceLocator.searchService(),
            workspaceService: serviceLocator.workspaceService(),
            relationsInteractor: relationsInteractor,
            relationDetailsStorage: serviceLocator.relationDetailsStorage()
        )
        
        let internalViewModel = RelationsSearchViewModel(
            document: document,
            excludedRelationsIds: excludedRelationsIds,
            target: target,
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
                output.didAskToShowCreateNewRelation(document: document, target: target, searchText: title)
            }),
            internalViewModel: internalViewModel
        )
        
        return NewSearchView(viewModel: viewModel)
    }
    
    func widgetSourceSearchModule(data: WidgetSourceSearchModuleModel) -> AnyView {
        return widgetSourceSearchModule(
            spaceId: data.spaceId,
            model: WidgetSourceSearchSelectInternalViewModel(context: data.context, onSelect: data.onSelect)
        )
    }
    
    func widgetChangeSourceSearchModule(data: WidgetChangeSourceSearchModuleModel) -> AnyView {
        return widgetSourceSearchModule(
            spaceId: data.spaceId,
            model: WidgetSourceSearchChangeInternalViewModel(
                widgetObjectId: data.widgetObjectId,
                widgetId: data.widgetId,
                documentService: self.serviceLocator.documentService(),
                blockWidgetService: self.serviceLocator.blockWidgetService(),
                context: data.context,
                onFinish: data.onFinish
            )
        )
    }
    
    // MARK: - Private
    
    private func widgetSourceSearchModule(
        spaceId: String,
        model: @autoclosure @escaping () -> WidgetSourceSearchInternalViewModelProtocol
    ) -> AnyView {
       return NewSearchView(
            viewModel: NewSearchViewModel(
                title: Loc.Widgets.sourceSearch,
                searchPlaceholder: Loc.search,
                style: .default,
                itemCreationMode: .unavailable,
                internalViewModel: WidgetSourceSearchViewModel(
                    interactor: WidgetSourceSearchInteractor(
                        spaceId: spaceId,
                        searchService: self.serviceLocator.searchService()
                    ),
                    internalModel: model()
                )
            )
        ).eraseToAnyView()
    }
}
