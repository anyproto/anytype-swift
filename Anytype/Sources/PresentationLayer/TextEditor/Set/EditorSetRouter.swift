import Foundation
import AnytypeCore
import Services
import UIKit
import SwiftUI

protocol EditorSetRouterProtocol:
    AnyObject,
    ObjectHeaderRouterProtocol
{
    
    func showSetSettings(subscriptionDetailsStorage: ObjectDetailsStorage)
    func showSetSettingsLegacy(onSettingTap: @escaping (EditorSetSetting) -> Void)
    func dismissSetSettingsIfNeeded()

    func showViewPicker(subscriptionDetailsStorage: ObjectDetailsStorage, showViewTypes: @escaping RoutingAction<DataviewView?>)
    
    func showCreateObject(setting: ObjectCreationSetting?)
    
    func showRelationSearch(relationsDetails: [RelationDetails], onSelect: @escaping (RelationDetails) -> Void)
    func showViewTypes(
        setDocument: SetDocumentProtocol,
        activeView: DataviewView?,
        dataviewService: DataviewServiceProtocol
    )
    
    func showViewSettings(setDocument: SetDocumentProtocol)
    func showSorts()
    func showFilters(setDocument: SetDocumentProtocol, subscriptionDetailsStorage: ObjectDetailsStorage)
    
    func showCardSizes(size: DataviewViewSize, onSelect: @escaping (DataviewViewSize) -> Void)
    func showCovers(setDocument: SetDocumentProtocol, onSelect: @escaping (String) -> Void)
    
    func showGroupByRelations(onSelect: @escaping (String) -> Void)
    
    func showKanbanColumnSettings(
        hideColumn: Bool,
        selectedColor: BlockBackgroundColor?,
        onSelect: @escaping (Bool, BlockBackgroundColor?) -> Void
    )
    
    func showSettings(actionHandler: @escaping (ObjectSettingsAction) -> Void)
    func showQueries(selectedObjectId: BlockId?, onSelect: @escaping (BlockId) -> ())

    func showRelationValueEditingView(key: String)
    func showRelationValueEditingView(objectDetails: ObjectDetails, relation: Relation)
    
    func showFailureToast(message: String)
    
    @MainActor
    func showSetObjectCreationSettings(
        setDocument: SetDocumentProtocol,
        viewId: String,
        onTemplateSelection: @escaping (ObjectCreationSetting) -> ()
    )
}

final class EditorSetRouter: EditorSetRouterProtocol, ObjectSettingsCoordinatorOutput, SetObjectCreationCoordinatorOutput {
    
    // MARK: - DI
    
    private let setDocument: SetDocumentProtocol
    private let navigationContext: NavigationContextProtocol
    private let createObjectModuleAssembly: CreateObjectModuleAssemblyProtocol
    private let newSearchModuleAssembly: NewSearchModuleAssemblyProtocol
    private let objectSettingCoordinator: ObjectSettingsCoordinatorProtocol
    private let relationValueCoordinator: RelationValueCoordinatorProtocol
    private let setObjectCreationCoordinator: SetObjectCreationCoordinatorProtocol
    private let objectCoverPickerModuleAssembly: ObjectCoverPickerModuleAssemblyProtocol
    private let objectIconPickerModuleAssembly: ObjectIconPickerModuleAssemblyProtocol
    private let setViewSettingsCoordinatorAssembly: SetViewSettingsCoordinatorAssemblyProtocol
    private let setSortsListCoordinatorAssembly: SetSortsListCoordinatorAssemblyProtocol
    private let setFiltersListCoordinatorAssembly: SetFiltersListCoordinatorAssemblyProtocol
    private let setViewSettingsImagePreviewModuleAssembly: SetViewSettingsImagePreviewModuleAssemblyProtocol
    private let setViewSettingsGroupByModuleAssembly: SetViewSettingsGroupByModuleAssemblyProtocol
    private let editorSetRelationsCoordinatorAssembly: SetRelationsCoordinatorAssemblyProtocol
    private let setViewPickerCoordinatorAssembly: SetViewPickerCoordinatorAssemblyProtocol
    private let toastPresenter: ToastPresenterProtocol
    private let setObjectCreationSettingsCoordinator: SetObjectCreationSettingsCoordinatorProtocol
    private var output: EditorSetModuleOutput?

    // MARK: - State
    
    private weak var currentSetSettingsPopup: AnytypePopup?
    
    init(
        setDocument: SetDocumentProtocol,
        navigationContext: NavigationContextProtocol,
        createObjectModuleAssembly: CreateObjectModuleAssemblyProtocol,
        newSearchModuleAssembly: NewSearchModuleAssemblyProtocol,
        objectSettingCoordinator: ObjectSettingsCoordinatorProtocol,
        relationValueCoordinator: RelationValueCoordinatorProtocol,
        setObjectCreationCoordinator: SetObjectCreationCoordinatorProtocol,
        objectCoverPickerModuleAssembly: ObjectCoverPickerModuleAssemblyProtocol,
        objectIconPickerModuleAssembly: ObjectIconPickerModuleAssemblyProtocol,
        setViewSettingsCoordinatorAssembly: SetViewSettingsCoordinatorAssemblyProtocol,
        setSortsListCoordinatorAssembly: SetSortsListCoordinatorAssemblyProtocol,
        setFiltersListCoordinatorAssembly: SetFiltersListCoordinatorAssemblyProtocol,
        setViewSettingsImagePreviewModuleAssembly: SetViewSettingsImagePreviewModuleAssemblyProtocol,
        setViewSettingsGroupByModuleAssembly: SetViewSettingsGroupByModuleAssemblyProtocol,
        editorSetRelationsCoordinatorAssembly: SetRelationsCoordinatorAssemblyProtocol,
        setViewPickerCoordinatorAssembly: SetViewPickerCoordinatorAssemblyProtocol,
        toastPresenter: ToastPresenterProtocol,
        setObjectCreationSettingsCoordinator: SetObjectCreationSettingsCoordinatorProtocol,
        output: EditorSetModuleOutput?
    ) {
        self.setDocument = setDocument
        self.navigationContext = navigationContext
        self.createObjectModuleAssembly = createObjectModuleAssembly
        self.newSearchModuleAssembly = newSearchModuleAssembly
        self.objectSettingCoordinator = objectSettingCoordinator
        self.relationValueCoordinator = relationValueCoordinator
        self.setObjectCreationCoordinator = setObjectCreationCoordinator
        self.objectCoverPickerModuleAssembly = objectCoverPickerModuleAssembly
        self.objectIconPickerModuleAssembly = objectIconPickerModuleAssembly
        self.setViewSettingsCoordinatorAssembly = setViewSettingsCoordinatorAssembly
        self.setSortsListCoordinatorAssembly = setSortsListCoordinatorAssembly
        self.setFiltersListCoordinatorAssembly = setFiltersListCoordinatorAssembly
        self.setViewSettingsImagePreviewModuleAssembly = setViewSettingsImagePreviewModuleAssembly
        self.setViewSettingsGroupByModuleAssembly = setViewSettingsGroupByModuleAssembly
        self.editorSetRelationsCoordinatorAssembly = editorSetRelationsCoordinatorAssembly
        self.setViewPickerCoordinatorAssembly = setViewPickerCoordinatorAssembly
        self.toastPresenter = toastPresenter
        self.setObjectCreationSettingsCoordinator = setObjectCreationSettingsCoordinator
        self.output = output
    }
    
    // MARK: - EditorSetRouterProtocol
    
    @MainActor
    func showSetSettings(subscriptionDetailsStorage: ObjectDetailsStorage) {
        let view = setViewSettingsCoordinatorAssembly.make(
            setDocument: setDocument,
            viewId: setDocument.activeView.id,
            mode: .edit,
            subscriptionDetailsStorage: subscriptionDetailsStorage
        )
        navigationContext.presentSwiftUISheetView(view: view)
    }
    
    func showSetSettingsLegacy(onSettingTap: @escaping (EditorSetSetting) -> Void) {
        guard let currentSetSettingsPopup = currentSetSettingsPopup else {
            showSetSettingsPopup(onSettingTap: onSettingTap)
            return
        }
        currentSetSettingsPopup.dismiss(animated: false) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.showSetSettingsPopup(onSettingTap: onSettingTap)
            }
        }
    }
    
    func dismissSetSettingsIfNeeded() {
        currentSetSettingsPopup?.dismiss(animated: false)
    }

    @MainActor
    func showViewPicker(
        subscriptionDetailsStorage: ObjectDetailsStorage,
        showViewTypes: @escaping RoutingAction<DataviewView?>
    ) {
        let view = setViewPickerCoordinatorAssembly.make(
            with: setDocument,
            subscriptionDetailsStorage: subscriptionDetailsStorage,
            showViewTypes: showViewTypes
        )
        navigationContext.presentSwiftUISheetView(view: view)
    }
    
    func showCreateObject(setting: ObjectCreationSetting?) {
        setObjectCreationCoordinator.startCreateObject(setDocument: setDocument, setting: setting, output: self, customAnalyticsRoute: nil)
    }
    
    func showRelationSearch(relationsDetails: [RelationDetails], onSelect: @escaping (RelationDetails) -> Void) {
        let vc = UIHostingController(
            rootView: newSearchModuleAssembly.setSortsSearchModule(
                relationsDetails: relationsDetails,
                onSelect: { [weak self] relationDetails in
                    self?.navigationContext.dismissTopPresented(animated: false) {
                        onSelect(relationDetails)
                    }
                }
            )
        )
        if #available(iOS 15.0, *) {
            if let sheet = vc.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                sheet.selectedDetentIdentifier = .large
            }
        }
        navigationContext.present(vc)
    }
    
    func showViewTypes(
        setDocument: SetDocumentProtocol,
        activeView: DataviewView?,
        dataviewService: DataviewServiceProtocol
    ) {
        let viewModel = SetViewTypesPickerViewModel(
            setDocument: setDocument,
            activeView: activeView,
            dataviewService: dataviewService,
            relationDetailsStorage: ServiceLocator.shared.relationDetailsStorage()
        )
        let vc = UIHostingController(
            rootView: SetViewTypesPicker(viewModel: viewModel)
        )
        if #available(iOS 15.0, *) {
            if let sheet = vc.sheetPresentationController {
                sheet.detents = [.large()]
                sheet.selectedDetentIdentifier = .large
            }
        }
        navigationContext.present(vc)
    }

    @MainActor
    func showViewSettings(setDocument: SetDocumentProtocol) {
        let view = editorSetRelationsCoordinatorAssembly.make(
            with: setDocument,
            viewId: setDocument.activeView.id
        )
        navigationContext.presentSwiftUIView(view: view)
    }
    
    @MainActor
    func showSorts() {
        let view = setSortsListCoordinatorAssembly.make(
            with: setDocument,
            viewId: setDocument.activeView.id
        )
        let vc = UIHostingController(
            rootView: view
        )
        presentSheet(vc, detents: [.large()], selectedDetentIdentifier: .large)
    }
    
    @MainActor
    func showFilters(setDocument: SetDocumentProtocol, subscriptionDetailsStorage: ObjectDetailsStorage) {
        let view = setFiltersListCoordinatorAssembly.make(
            with: setDocument,
            viewId: setDocument.activeView.id,
            subscriptionDetailsStorage: subscriptionDetailsStorage
        )
        let vc = UIHostingController(
            rootView: view
        )
        presentSheet(vc, detents: [.large()], selectedDetentIdentifier: .large)
    }
    
    @MainActor
    func showCardSizes(size: DataviewViewSize, onSelect: @escaping (DataviewViewSize) -> Void) {
        let view = CheckPopupView(
            viewModel: SetViewSettingsCardSizeViewModel(
                selectedSize: size,
                onSelect: onSelect
            )
        )
        presentSheet(
            AnytypePopup(
                contentView: view
            )
        )
    }
    
    @MainActor
    func showCovers(setDocument: SetDocumentProtocol, onSelect: @escaping (String) -> Void) {
        let view = setViewSettingsImagePreviewModuleAssembly.make(
            setDocument: setDocument,
            onSelect: onSelect
        )
        let vc = UIHostingController(rootView: view)
        presentSheet(vc)
    }
    
    @MainActor
    func showGroupByRelations(onSelect: @escaping (String) -> Void) {
        let view = setViewSettingsGroupByModuleAssembly.make(
            setDocument: setDocument,
            onSelect: onSelect
        )
        presentSheet(
            AnytypePopup(
                contentView: view
            )
        )
    }
    
    func showKanbanColumnSettings(
        hideColumn: Bool,
        selectedColor: BlockBackgroundColor?,
        onSelect: @escaping (Bool, BlockBackgroundColor?) -> Void
    ) {
        let popup = AnytypePopup(
            viewModel: SetKanbanColumnSettingsViewModel(
                hideColumn: hideColumn,
                selectedColor: selectedColor,
                onApplyTap: { [weak self] hidden, backgroundColor in
                    onSelect(hidden, backgroundColor)
                    self?.navigationContext.dismissTopPresented()
                }
            ),
            configuration: .init(
                isGrabberVisible: true,
                dismissOnBackdropView: true
            )
        )
        navigationContext.present(popup)
    }
    
    func showSettings(actionHandler: @escaping (ObjectSettingsAction) -> Void) {
        objectSettingCoordinator.startFlow(
            objectId: setDocument.objectId,
            delegate: self,
            output: self,
            objectSettingsHandler: actionHandler
        )
    }
    
    func showCoverPicker(
        document: BaseDocumentGeneralProtocol,
        onCoverAction: @escaping (ObjectCoverPickerAction) -> Void
    ) {
        let moduleViewController = objectCoverPickerModuleAssembly.make(
            document: document,
            onCoverAction: onCoverAction
        )
        navigationContext.present(moduleViewController)
    }
    
    func showIconPicker(document: BaseDocumentGeneralProtocol, onIconAction: @escaping (ObjectIconPickerAction) -> Void) {
        let moduleViewController = objectIconPickerModuleAssembly.make(
            document: setDocument,
            onIconAction: onIconAction
        )
        navigationContext.present(moduleViewController)
    }
    
    func showQueries(selectedObjectId: BlockId?, onSelect: @escaping (BlockId) -> ()) {
        showTypesSearch(
            title: Loc.Set.SourceType.selectQuery,
            selectedObjectId: selectedObjectId,
            showBookmark: true,
            showSetAndCollection: false,
            onSelect: onSelect
        )
    }
    
    func closeEditor() {
        Task { @MainActor in
            output?.closeEditor()
        }
    }
    
    func showRelationValueEditingView(key: String) {
        let relation = setDocument.parsedRelations.installed.first { $0.key == key }
        guard let relation = relation else { return }
        guard let objectDetails = setDocument.details else {
            anytypeAssertionFailure("Set document doesn't contains details")
            return
        }
        showRelationValueEditingView(objectDetails: objectDetails, relation: relation)
    }
    
    func showRelationValueEditingView(objectDetails: ObjectDetails, relation: Relation) {
        relationValueCoordinator.startFlow(objectDetails: objectDetails, relation: relation, analyticsType: .dataview, output: self)
    }
    
    func showPage(data: EditorScreenData) {
        Task { @MainActor in
            output?.showEditorScreen(data: data)
        }
    }
    
    func showFailureToast(message: String) {
        toastPresenter.showFailureAlert(message: message)
    }
    
    @MainActor
    func showSetObjectCreationSettings(
        setDocument: SetDocumentProtocol,
        viewId: String,
        onTemplateSelection: @escaping (ObjectCreationSetting) -> ()
    ) {
        setObjectCreationSettingsCoordinator.showSetObjectCreationSettings(
            setDocument: setDocument,
            viewId: viewId,
            onTemplateSelection: onTemplateSelection
        )
    }
    
    // MARK: - SetObjectCreationCoordinatorOutput
    
    func showEditorScreen(data: EditorScreenData) {
        showPage(data: data)
    }

    // MARK: - Private
    
    private func showTypesSearch(
        title: String,
        selectedObjectId: BlockId?,
        showBookmark: Bool,
        showSetAndCollection: Bool,
        onSelect: @escaping (BlockId) -> ()
    ) {
        let view = newSearchModuleAssembly.objectTypeSearchModule(
            title: title,
            spaceId: setDocument.spaceId,
            selectedObjectId: selectedObjectId,
            excludedObjectTypeId: setDocument.details?.type,
            showBookmark: showBookmark,
            showSetAndCollection: showSetAndCollection
        ) { [weak self] type in
            self?.navigationContext.dismissTopPresented()
            onSelect(type.id)
        }
        
        navigationContext.presentSwiftUIView(view: view)
    }
    
    private func presentSheet(
        _ vc: UIViewController,
        detents: [UISheetPresentationController.Detent] = [.medium(), .large()],
        selectedDetentIdentifier: UISheetPresentationController.Detent.Identifier = .medium
    ) {
        if let sheet = vc.sheetPresentationController {
            sheet.detents = detents
            sheet.selectedDetentIdentifier = selectedDetentIdentifier
        }
        navigationContext.present(vc)
    }
    
    private func showSetSettingsPopup(onSettingTap: @escaping (EditorSetSetting) -> Void) {
        let popup = AnytypePopup(
            viewModel: EditorSetSettingsViewModel(onSettingTap: onSettingTap),
            floatingPanelStyle: true,
            configuration: .init(
                isGrabberVisible: true,
                dismissOnBackdropView: false,
                skipThroughGestures: true
            )
        )
        currentSetSettingsPopup = popup
        navigationContext.present(popup)
    }
}

extension EditorSetRouter: RelationValueCoordinatorOutput {
    func openObject(screenData: EditorScreenData) {
        navigationContext.dismissAllPresented()
        showPage(data: screenData)
    }
}

extension EditorSetRouter: ObjectSettingsModuleDelegate {
    func didCreateTemplate(templateId: Services.BlockId) {
        anytypeAssertionFailure("Should be disabled in restrictions. Check template restrinctions")
    }
    
    func didCreateLinkToItself(selfName: String, data: EditorScreenData) {
        guard let objectId = data.objectId else { return }
        UIApplication.shared.hideKeyboard()
        toastPresenter.showObjectName(selfName, middleAction: Loc.Editor.Toast.linkedTo, secondObjectId: objectId) { [weak self] in
            self?.showPage(data: data)
        }
    }
    
    func didTapUseTemplateAsDefault(templateId: BlockId) {
        anytypeAssertionFailure("Invalid delegate method handler")
    }
}
