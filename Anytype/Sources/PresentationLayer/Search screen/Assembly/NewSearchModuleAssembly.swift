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
        relationKey: String,
        selectedStatusesIds: [String],
        onSelect: @escaping (_ ids: [String]) -> Void,
        onCreate: @escaping (_ title: String) -> Void
    ) -> NewSearchView {
        let interactor = StatusSearchInteractor(
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
        relationKey: String,
        selectedTagIds: [String],
        onSelect: @escaping (_ ids: [String]) -> Void,
        onCreate: @escaping (_ title: String) -> Void
    ) -> NewSearchView {
        let interactor = TagsSearchInteractor(
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
        style: NewSearchView.Style,
        selectionMode: NewSearchViewModel.SelectionMode,
        excludedObjectIds: [String],
        limitedObjectType: [String],
        onSelect: @escaping (_ details: [ObjectDetails]) -> Void
    ) -> NewSearchView {
        let interactor = ObjectsSearchInteractor(
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
        spaceId: String,
        selectedObjectId: BlockId?,
        excludedObjectTypeId: String?,
        showBookmark: Bool,
        showSetAndCollection: Bool,
        browser: EditorBrowserController?,
        onSelect: @escaping (_ type: ObjectType) -> Void
    ) -> NewSearchView {
        let interactor = ObjectTypesSearchInteractor(
            spaceId: spaceId,
            searchService: serviceLocator.searchService(),
            workspaceService: serviceLocator.workspaceService(),
            excludedObjectTypeId: excludedObjectTypeId,
            showBookmark: showBookmark,
            showSetAndCollection: showSetAndCollection
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
        spaceId: String,
        onSelect: @escaping (_ ids: [String]) -> Void
    ) -> NewSearchView {
        let interactor = ObjectTypesSearchInteractor(
            spaceId: spaceId,
            searchService: serviceLocator.searchService(),
            workspaceService: serviceLocator.workspaceService(),
            excludedObjectTypeId: nil,
            showBookmark: false,
            showSetAndCollection: false
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
        excludedTypeIds: [String],
        onSelect: @escaping (_ details: ObjectDetails) -> Void
    ) -> NewSearchView {
        let interactor = BlockObjectsSearchInteractor(
            searchService: serviceLocator.searchService(),
            excludedObjectIds: excludedObjectIds,
            excludedTypeIds: excludedTypeIds
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
        target: RelationsSearchTarget,
        output: RelationSearchModuleOutput
    ) -> NewSearchView {
        
        let interactor = RelationsSearchInteractor(
            searchService: serviceLocator.searchService(),
            workspaceService: serviceLocator.workspaceService(),
            relationsService: RelationsService(objectId: document.objectId),
            dataviewService: DataviewService(
                objectId: document.objectId,
                blockId: nil,
                prefilledFieldsBuilder: SetPrefilledFieldsBuilder()
            )
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
                output.didAskToShowCreateNewRelation(document: document, searchText: title)
            }),
            internalViewModel: internalViewModel
        )
        
        return NewSearchView(viewModel: viewModel)
    }
    
    func widgetSourceSearchModule(
        context: AnalyticsWidgetContext,
        onSelect: @escaping (_ source: WidgetSource) -> Void
    ) -> AnyView {
        let model = WidgetSourceSearchSelectInternalViewModel(context: context, onSelect: onSelect)
        return widgetSourceSearchModule(model: model)
    }
    
    func widgetChangeSourceSearchModule(
        widgetObjectId: String,
        widgetId: String,
        context: AnalyticsWidgetContext,
        onFinish: @escaping () -> Void
    ) -> AnyView {
        let model = WidgetSourceSearchChangeInternalViewModel(
            widgetObjectId: widgetObjectId,
            widgetId: widgetId,
            documentService: serviceLocator.documentService(),
            blockWidgetService: serviceLocator.blockWidgetService(),
            context: context,
            onFinish: onFinish
        )
        return widgetSourceSearchModule(model: model)
    }
    
    // MARK: - Private
    
    private func widgetSourceSearchModule(model: WidgetSourceSearchInternalViewModelProtocol) -> AnyView {
        let interactor = WidgetSourceSearchInteractor(searchService: serviceLocator.searchService())
        
        let internalViewModel = WidgetSourceSearchViewModel(interactor: interactor, internalModel: model)
        
        let viewModel = NewSearchViewModel(
            title: Loc.Widgets.sourceSearch,
            searchPlaceholder: Loc.search,
            style: .default,
            itemCreationMode: .unavailable,
            internalViewModel: internalViewModel
        )
        
        return NewSearchView(viewModel: viewModel).eraseToAnyView()
    }
}
