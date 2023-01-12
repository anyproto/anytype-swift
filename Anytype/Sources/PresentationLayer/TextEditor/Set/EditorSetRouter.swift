import Foundation
import AnytypeCore
import BlocksModels
import UIKit
import SwiftUI

protocol EditorSetRouterProtocol: AnyObject {
    
    func showSetSettings(onSettingTap: @escaping (EditorSetSetting) -> Void)
    func dismissSetSettingsIfNeeded()
    
    func setNavigationViewHidden(_ isHidden: Bool, animated: Bool)
    func showViewPicker(
        setDocument: SetDocumentProtocol,
        dataviewService: DataviewServiceProtocol,
        showViewTypes: @escaping RoutingAction<DataviewView?>
    )
    
    func showCreateObject(pageId: BlockId)
    func showCreateBookmarkObject()
    
    func showRelationSearch(relationsDetails: [RelationDetails], onSelect: @escaping (RelationDetails) -> Void)
    func showViewTypes(
        dataView: BlockDataview,
        activeView: DataviewView?,
        dataviewService: DataviewServiceProtocol
    )
    
    func showViewSettings(setDocument: SetDocumentProtocol, dataviewService: DataviewServiceProtocol)
    func showSorts(setDocument: SetDocumentProtocol, dataviewService: DataviewServiceProtocol)
    func showFilters(setDocument: SetDocumentProtocol, dataviewService: DataviewServiceProtocol)
    func showFilterSearch(filter: SetFilter, onApply: @escaping (SetFilter) -> Void)
    
    func showCardSizes(size: DataviewViewSize, onSelect: @escaping (DataviewViewSize) -> Void)
    func showCovers(setDocument: SetDocumentProtocol, onSelect: @escaping (String) -> Void)
    
    func showGroupByRelations(
        selectedRelationKey: String,
        relations: [RelationDetails],
        onSelect: @escaping (String) -> Void
    )
    
    func showKanbanColumnSettings(
        hideColumn: Bool,
        selectedColor: BlockBackgroundColor?,
        onSelect: @escaping (Bool, BlockBackgroundColor?) -> Void
    )
    
    func showFiltersDaysView(title: String, days: Int, onApply: @escaping (Int) -> Void)
    func showFilterConditions(filter: SetFilter, onSelect: @escaping (DataviewFilter.Condition) -> Void)
    func showSortTypesList(setSort: SetSort, onSelect: @escaping (SetSort) -> Void)
    
    func showAddNewRelationView(onSelect: ((RelationDetails, _ isNew: Bool) -> Void)?)
    func showSettings()
    
    func showSources(selectedObjectId: BlockId?, onSelect: @escaping (BlockId) -> ())
}

final class EditorSetRouter: EditorSetRouterProtocol, ObjectSettingsModuleDelegate {
    
    // MARK: - DI
    
    private let document: BaseDocumentProtocol
    private weak var rootController: EditorBrowserController?
    private let navigationContext: NavigationContextProtocol
    private let createObjectModuleAssembly: CreateObjectModuleAssemblyProtocol
    private let newSearchModuleAssembly: NewSearchModuleAssemblyProtocol
    private let editorPageCoordinator: EditorPageCoordinatorProtocol
    private let addNewRelationCoordinator: AddNewRelationCoordinatorProtocol
    private let objectSettingCoordinator: ObjectSettingsCoordinatorProtocol
    private let toastPresenter: ToastPresenterProtocol
    private let alertHelper: AlertHelper
    
    // MARK: - State
    
    private weak var currentSetSettingsPopup: AnytypePopup?
    
    init(
        document: BaseDocumentProtocol,
        rootController: EditorBrowserController?,
        navigationContext: NavigationContextProtocol,
        createObjectModuleAssembly: CreateObjectModuleAssemblyProtocol,
        newSearchModuleAssembly: NewSearchModuleAssemblyProtocol,
        editorPageCoordinator: EditorPageCoordinatorProtocol,
        addNewRelationCoordinator: AddNewRelationCoordinatorProtocol,
        objectSettingCoordinator: ObjectSettingsCoordinatorProtocol,
        toastPresenter: ToastPresenterProtocol,
        alertHelper: AlertHelper
    ) {
        self.document = document
        self.rootController = rootController
        self.navigationContext = navigationContext
        self.createObjectModuleAssembly = createObjectModuleAssembly
        self.newSearchModuleAssembly = newSearchModuleAssembly
        self.editorPageCoordinator = editorPageCoordinator
        self.addNewRelationCoordinator = addNewRelationCoordinator
        self.objectSettingCoordinator = objectSettingCoordinator
        self.toastPresenter = toastPresenter
        self.alertHelper = alertHelper
    }
    
    // MARK: - EditorSetRouterProtocol
    
    func showSetSettings(onSettingTap: @escaping (EditorSetSetting) -> Void) {
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
    
    func setNavigationViewHidden(_ isHidden: Bool, animated: Bool) {
        rootController?.setNavigationViewHidden(isHidden, animated: animated)
    }
    
    func showViewPicker(
        setDocument: SetDocumentProtocol,
        dataviewService: DataviewServiceProtocol,
        showViewTypes: @escaping RoutingAction<DataviewView?>)
    {
        let viewModel = EditorSetViewPickerViewModel(
            setDocument: setDocument,
            dataviewService: dataviewService,
            showViewTypes: showViewTypes
        )
        let vc = UIHostingController(
            rootView: EditorSetViewPicker(viewModel: viewModel)
        )
        presentSheet(vc)
    }
    
    func showCreateObject(pageId: BlockId) {
        let moduleViewController = createObjectModuleAssembly.makeCreateObject(objectId: pageId) { [weak self] in
            self?.navigationContext.dismissTopPresented()
            self?.showPage(data: EditorScreenData(pageId: pageId, type: .page))
        } closeAction: { [weak self] in
            self?.navigationContext.dismissTopPresented()
        }
        
        navigationContext.present(moduleViewController)
    }
    
    func showCreateBookmarkObject() {
        let moduleViewController = createObjectModuleAssembly.makeCreateBookmark(
            closeAction: { [weak self] withError in
                self?.navigationContext.dismissTopPresented(animated: true) {
                    guard withError else { return }
                    self?.alertHelper.showToast(
                        title: Loc.Set.Bookmark.Error.title,
                        message: Loc.Set.Bookmark.Error.message
                    )
                }
            }
        )
        
        navigationContext.present(moduleViewController)
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
        dataView: BlockDataview,
        activeView: DataviewView?,
        dataviewService: DataviewServiceProtocol
    )
    {
        let viewModel = SetViewTypesPickerViewModel(
            dataView: dataView,
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
    
    func showViewSettings(setDocument: SetDocumentProtocol, dataviewService: DataviewServiceProtocol) {
        let viewModel = EditorSetViewSettingsViewModel(
            setDocument: setDocument,
            service: dataviewService,
            router: self
        )
        let view = EditorSetViewSettingsView(
            model: viewModel
        )
        navigationContext.presentSwiftUIView(view: view)
    }
    
    func showSorts(setDocument: SetDocumentProtocol, dataviewService: DataviewServiceProtocol) {
        let viewModel = SetSortsListViewModel(
            setDocument: setDocument,
            service: dataviewService,
            router: self
        )
        let vc = UIHostingController(
            rootView: SetSortsListView(viewModel: viewModel)
        )
        presentSheet(vc)
    }
    
    func showFilters(setDocument: SetDocumentProtocol, dataviewService: DataviewServiceProtocol) {
        let viewModel = SetFiltersListViewModel(
            setDocument: setDocument,
            dataviewService: dataviewService,
            router: self
        )
        let vc = UIHostingController(
            rootView: SetFiltersListView(viewModel: viewModel)
        )
        presentSheet(vc)
    }
    
    func showFilterSearch(
        filter: SetFilter,
        onApply: @escaping (SetFilter) -> Void
    ) {
        let viewModel = SetFiltersSelectionViewModel(
            filter: filter,
            router: self,
            newSearchModuleAssembly: newSearchModuleAssembly,
            onApply: { [weak self] filter in
                onApply(filter)
                self?.navigationContext.dismissTopPresented()
            }
        )
        let popup = AnytypePopup(viewModel: viewModel)
        navigationContext.present(popup)
    }
    
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
    
    func showCovers(setDocument: SetDocumentProtocol, onSelect: @escaping (String) -> Void) {
        let viewModel = SetViewSettingsImagePreviewViewModel(
            setDocument: setDocument,
            onSelect: onSelect
        )
        let vc = UIHostingController(
            rootView: SetViewSettingsImagePreviewView(
                viewModel: viewModel
            )
        )
        presentSheet(vc)
    }
    
    func showGroupByRelations(
        selectedRelationKey: String,
        relations: [RelationDetails],
        onSelect: @escaping (String) -> Void
    ) {
        let view = CheckPopupView(
            viewModel: SetViewSettingsGroupByViewModel(
                selectedRelationKey: selectedRelationKey,
                relations: relations,
                onSelect: onSelect
            )
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
    
    func showFiltersDaysView(title: String, days: Int, onApply: @escaping (Int) -> Void) {
        let viewModel =  SetFiltersDaysViewModel(
            title: title,
            value: "\(days)",
            onValueChanged: { value in
                let result = Int(Double(value) ?? 0)
                onApply(result)
            }
        )
        let popup = AnytypePopup(viewModel: viewModel)
        navigationContext.present(popup)
    }
    
    func showFilterConditions(filter: SetFilter, onSelect: @escaping (DataviewFilter.Condition) -> Void) {
        let view = CheckPopupView(
            viewModel: SetFilterConditionsViewModel(
                filter: filter,
                onSelect: { condition in
                    onSelect(condition)
                }
            )
        )
        let popul = AnytypePopup(contentView: view)
        presentSheet(popul)
    }
    
    func showSortTypesList(setSort: SetSort, onSelect: @escaping (SetSort) -> Void) {
        let view = CheckPopupView(viewModel: SetSortTypesListViewModel(
            sort: setSort,
            onSelect: { sort in
                let newSetSort = SetSort(
                    relationDetails: setSort.relationDetails,
                    sort: sort
                )
                onSelect(newSetSort)
            })
        )
        let popup = AnytypePopup(contentView: view)
        presentSheet(popup)
    }
    
    func showAddNewRelationView(onSelect: ((RelationDetails, _ isNew: Bool) -> Void)?) {
        addNewRelationCoordinator.showAddNewRelationView(onCompletion: onSelect)
    }
    
    func showSettings() {
        objectSettingCoordinator.startFlow(delegate: self)
    }
    
    func showSources(selectedObjectId: BlockId?, onSelect: @escaping (BlockId) -> ()) {
        showTypesSearch(
            title: Loc.Set.SourceType.selectSource,
            selectedObjectId: selectedObjectId,
            showBookmark: true,
            showSet: false,
            onSelect: onSelect
        )
    }
    
    // MARK: - ObjectSettingsModuleDelegate

    func didCreateLinkToItself(selfName: String, in objectId: BlockId) {
        UIApplication.shared.hideKeyboard()
        toastPresenter.showObjectName(selfName, middleAction: Loc.Editor.Toast.linkedTo, secondObjectId: objectId) { [weak self] in
            self?.showPage(data: .init(pageId: objectId, type: .page))
        }
    }
    
    // MARK: - Private
    
    private func showTypesSearch(
        title: String,
        selectedObjectId: BlockId?,
        showBookmark: Bool,
        showSet: Bool,
        onSelect: @escaping (BlockId) -> ()
    ) {
        let view = newSearchModuleAssembly.objectTypeSearchModule(
            title: title,
            selectedObjectId: selectedObjectId,
            excludedObjectTypeId: document.details?.type,
            showBookmark: showBookmark,
            showSet: showSet,
            browser: rootController
        ) { [weak self] type in
            self?.navigationContext.dismissTopPresented()
            onSelect(type.id)
        }
        
        navigationContext.presentSwiftUIView(view: view)
    }
    
    private func showPage(data: EditorScreenData) {
        editorPageCoordinator.startFlow(data: data, replaceCurrentPage: false)
    }
    
    private func presentSheet(_ vc: UIViewController) {
        if #available(iOS 15.0, *) {
            if let sheet = vc.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                sheet.selectedDetentIdentifier = .medium
            }
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
