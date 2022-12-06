import UIKit
import BlocksModels
import SafariServices
import SwiftUI
import FloatingPanel
import AnytypeCore

final class EditorRouter: NSObject, EditorRouterProtocol {
    private weak var rootController: EditorBrowserController?
    private weak var viewController: UIViewController?
    private let navigationContext: NavigationContextProtocol
    private let fileCoordinator: FileDownloadingCoordinator
    private let addNewRelationCoordinator: AddNewRelationCoordinatorProtocol
    private let document: BaseDocumentProtocol
    private let templatesCoordinator: TemplatesCoordinator
    private let urlOpener: URLOpenerProtocol
    private let relationValueCoordinator: RelationValueCoordinatorProtocol
    private weak var currentSetSettingsPopup: AnytypePopup?
    private let editorPageCoordinator: EditorPageCoordinatorProtocol
    private let linkToObjectCoordinator: LinkToObjectCoordinatorProtocol
    private let objectCoverPickerModuleAssembly: ObjectCoverPickerModuleAssemblyProtocol
    private let objectIconPickerModuleAssembly: ObjectIconPickerModuleAssemblyProtocol
    private let objectSettingCoordinator: ObjectSettingsCoordinatorProtocol
    private let searchModuleAssembly: SearchModuleAssemblyProtocol
    private let toastPresenter: ToastPresenterProtocol
    private let alertHelper: AlertHelper
    
    init(
        rootController: EditorBrowserController?,
        viewController: UIViewController,
        navigationContext: NavigationContextProtocol,
        document: BaseDocumentProtocol,
        addNewRelationCoordinator: AddNewRelationCoordinatorProtocol,
        templatesCoordinator: TemplatesCoordinator,
        urlOpener: URLOpenerProtocol,
        relationValueCoordinator: RelationValueCoordinatorProtocol,
        editorPageCoordinator: EditorPageCoordinatorProtocol,
        linkToObjectCoordinator: LinkToObjectCoordinatorProtocol,
        objectCoverPickerModuleAssembly: ObjectCoverPickerModuleAssemblyProtocol,
        objectIconPickerModuleAssembly: ObjectIconPickerModuleAssemblyProtocol,
        objectSettingCoordinator: ObjectSettingsCoordinatorProtocol,
        searchModuleAssembly: SearchModuleAssemblyProtocol,
        toastPresenter: ToastPresenterProtocol,
        alertHelper: AlertHelper
    ) {
        self.rootController = rootController
        self.viewController = viewController
        self.navigationContext = navigationContext
        self.document = document
        self.fileCoordinator = FileDownloadingCoordinator(viewController: viewController)
        self.addNewRelationCoordinator = addNewRelationCoordinator
        self.templatesCoordinator = templatesCoordinator
        self.urlOpener = urlOpener
        self.relationValueCoordinator = relationValueCoordinator
        self.editorPageCoordinator = editorPageCoordinator
        self.linkToObjectCoordinator = linkToObjectCoordinator
        self.objectCoverPickerModuleAssembly = objectCoverPickerModuleAssembly
        self.objectIconPickerModuleAssembly = objectIconPickerModuleAssembly
        self.objectSettingCoordinator = objectSettingCoordinator
        self.searchModuleAssembly = searchModuleAssembly
        self.toastPresenter = toastPresenter
        self.alertHelper = alertHelper
    }
    
    func showToastMessage(attributedString: NSAttributedString) {
        toastPresenter.show(message: attributedString, mode: .aboveKeyboard)
    }

    func showPage(data: EditorScreenData) {
        editorPageCoordinator.startFlow(data: data, replaceCurrentPage: false)
    }

    func replaceCurrentPage(with data: EditorScreenData) {
        editorPageCoordinator.startFlow(data: data, replaceCurrentPage: true)
    }
    
    func showAlert(alertModel: AlertModel) {
        let alertController = AlertsFactory.alertController(from: alertModel)
        navigationContext.present(alertController)
    }
    
    func showLinkContextualMenu(inputParameters: TextBlockURLInputParameters) {
        let contextualMenuView = EditorContextualMenuView(
            options: [.pasteAsLink, .createBookmark, .pasteAsText],
            optionTapHandler: { [weak self] option in
                self?.navigationContext.dismissTopPresented(animated: false)
                inputParameters.optionHandler(option)
            }
        )

        let hostViewController = UIHostingController(rootView: contextualMenuView)
        hostViewController.modalPresentationStyle = .popover

        hostViewController.preferredContentSize = hostViewController
            .sizeThatFits(in: hostViewController.view.bounds.size)

        if let popoverPresentationController = hostViewController.popoverPresentationController {
            popoverPresentationController.sourceRect = inputParameters.rect
            popoverPresentationController.sourceView = inputParameters.textView
            popoverPresentationController.delegate = self
            popoverPresentationController.permittedArrowDirections = [.up, .down]
            navigationContext.present(hostViewController)
        }
    }
    
    func openUrl(_ url: URL) {
        urlOpener.openUrl(url)
    }
    
    func showBookmarkBar(completion: @escaping (AnytypeURL) -> ()) {
        showURLInputViewController { url in
            guard let url = url else { return }
            completion(url)
        }
    }
    
    func showLinkMarkup(url: AnytypeURL?, completion: @escaping (AnytypeURL?) -> Void) {
        showURLInputViewController(url: url, completion: completion)
    }
    
    func showFilePicker(model: Picker.ViewModel) {
        let vc = Picker(model)
        navigationContext.present(vc)
    }
    
    func showImagePicker(contentType: MediaPickerContentType, onSelect: @escaping (NSItemProvider?) -> Void) {
        let vc = UIHostingController(
            rootView: MediaPickerView(
                contentType: contentType,
                onSelect: onSelect
            )
        )
        navigationContext.present(vc)
    }
    
    func saveFile(fileURL: URL, type: FileContentType) {
        fileCoordinator.downloadFileAt(fileURL, withType: type)
    }
    
    func showCodeLanguageView(languages: [CodeLanguage], completion: @escaping (CodeLanguage) -> Void) {
        let searchListViewController = SearchListViewController(items: languages, completion: completion)
        searchListViewController.modalPresentationStyle = .pageSheet
        navigationContext.present(searchListViewController)
    }
    
    func showStyleMenu(
        information: BlockInformation,
        restrictions: BlockRestrictions,
        didShow: @escaping (UIView) -> Void,
        onDismiss: @escaping () -> Void
    ) {
        guard let controller = viewController,
              let rootController = rootController,
              let info = document.infoContainer.get(id: information.id) else { return }
        guard let controller = controller as? EditorPageController else {
            anytypeAssertionFailure("Not supported type of controller: \(controller)", domain: .editorPage)
            return
        }

        let popup = BottomSheetsFactory.createStyleBottomSheet(
            parentViewController: rootController,
            info: info,
            actionHandler: controller.viewModel.actionHandler,
            restrictions: restrictions,
            showMarkupMenu: { [weak controller, weak rootController, weak self] styleView, viewDidClose in
                guard let self = self else { return }
                guard let controller = controller else { return }
                guard let rootController = rootController else { return }

                BottomSheetsFactory.showMarkupBottomSheet(
                    parentViewController: rootController,
                    styleView: styleView,
                    document: self.document,
                    blockId: info.id,
                    actionHandler: controller.viewModel.actionHandler,
                    linkToObjectCoordinator: self.linkToObjectCoordinator,
                    viewDidClose: viewDidClose
                )
            },
            onDismiss: onDismiss
        )

        guard let popup = popup else {
            return
        }

        popup.addPanel(toParent: controller, animated: true) {
            didShow(popup.surfaceView)
        }
    }
    
    func showMoveTo(onSelect: @escaping (BlockId) -> ()) {
        
        let moveToView = NewSearchModuleAssembly.blockObjectsSearchModule(
            title: Loc.moveTo,
            excludedObjectIds: [document.objectId]
        ) { [weak self] details in
            onSelect(details.id)
            self?.navigationContext.dismissTopPresented()
        }

        navigationContext.presentSwiftUIView(view: moveToView, model: nil)
    }

    func showLinkTo(onSelect: @escaping (ObjectDetails) -> ()) {
        let moduleView = NewSearchModuleAssembly.blockObjectsSearchModule(
            title: Loc.linkTo,
            excludedObjectIds: [document.objectId]
        ) { [weak self] details in
            onSelect(details)
            self?.navigationContext.dismissTopPresented()
        }

        navigationContext.presentSwiftUIView(view: moduleView)
    }

    func showTextIconPicker(contextId: BlockId, objectId: BlockId) {
        let viewModel = TextIconPickerViewModel(
            fileService: FileActionsService(),
            textService: TextService(),
            contextId: contextId,
            objectId: objectId
        )

        let iconPicker = ObjectBasicIconPicker(viewModel: viewModel) { [weak self] in
            self?.navigationContext.dismissTopPresented()
        }

        navigationContext.presentSwiftUIView(view: iconPicker, model: nil)
    }
    
    func showSearch(onSelect: @escaping (EditorScreenData) -> ()) {
        let module = searchModuleAssembly.makeObjectSearch(title: nil, context: .menuSearch) { data in
            onSelect(EditorScreenData(pageId: data.blockId, type: data.viewType))
        }
        navigationContext.present(module)
    }
    
    func showTypes(selectedObjectId: BlockId?, onSelect: @escaping (BlockId) -> ()) {
        showTypesSearch(
            title: Loc.changeType,
            selectedObjectId: selectedObjectId,
            showBookmark: false,
            showSet: false,
            onSelect: onSelect
        )
    }
    
    func showTypesForEmptyObject(
        selectedObjectId: BlockId?,
        onSelect: @escaping (BlockId) -> ()
    ) {
        showTypesSearch(
            title: Loc.changeType,
            selectedObjectId: selectedObjectId,
            showBookmark: false,
            showSet: true,
            onSelect: onSelect
        )
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
    
    func showWaitingView(text: String) {
        let popup = PopupViewBuilder.createWaitingPopup(text: text)
        navigationContext.present(popup)
    }

    func hideWaitingView() {
        navigationContext.dismissTopPresented()
    }
    
    func closeEditor() {
        guard let viewController else { return }
        rootController?.popIfPresent(viewController)
    }
    
    func presentSheet(_ vc: UIViewController) {
        if #available(iOS 15.0, *) {
            if let sheet = vc.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                sheet.selectedDetentIdentifier = .medium
            }
        }
        navigationContext.present(vc)
    }
    
    func presentFullscreen(_ vc: UIViewController) {
        navigationContext.present(vc)
    }
    
    func setNavigationViewHidden(_ isHidden: Bool, animated: Bool) {
        rootController?.setNavigationViewHidden(isHidden, animated: animated)
    }

    func showObjectPreview(
        blockLinkState: BlockLinkState,
        onSelect: @escaping (BlockLink.Appearance) -> Void
    ) {
        let router = ObjectPreviewRouter(viewController: viewController)
        let viewModel = ObjectPreviewViewModel(
            blockLinkState: blockLinkState,
            router: router,
            onSelect: onSelect
        )

        let contentView = ObjectPreviewView(viewModel: viewModel)
        let popup = AnytypePopup(contentView: contentView)

        navigationContext.present(popup)

    }

    func showTemplatesPopupIfNeeded(
        document: BaseDocumentProtocol,
        templatesTypeId: ObjectTypeId,
        onShow: (() -> Void)?
    ) {
        templatesCoordinator.showTemplatesPopupIfNeeded(
            document: document,
            templatesTypeId: .dynamic(templatesTypeId.rawValue),
            onShow: onShow
        )
    }
    
    func showTemplatesPopupWithTypeCheckIfNeeded(
        document: BaseDocumentProtocol,
        templatesTypeId: ObjectTypeId,
        onShow: (() -> Void)?
    ) {
        templatesCoordinator.showTemplatesPopupWithTypeCheckIfNeeded(
            document: document,
            templatesTypeId: .dynamic(templatesTypeId.rawValue),
            onShow: onShow
        )
    }
    
    // MARK: - Settings
    func showSettings() {
        objectSettingCoordinator.startFlow(delegate: self)
    }
    
    func showCoverPicker() {
        let moduleViewController = objectCoverPickerModuleAssembly.make(document: document)
        navigationContext.present(moduleViewController)
    }
    
    func showIconPicker() {
        let moduleViewController = objectIconPickerModuleAssembly.make(document: document)
        navigationContext.present(moduleViewController)
    }

    func showColorPicker(
        onColorSelection: @escaping (ColorView.ColorItem) -> Void,
        selectedColor: UIColor?,
        selectedBackgroundColor: UIColor?
    ) {
        guard let rootController = rootController else { return }

        let styleColorViewController = StyleColorViewController(
            selectedColor: selectedColor,
            selectedBackgroundColor: selectedBackgroundColor,
            onColorSelection: onColorSelection) { viewController in
                viewController.removeFromParentEmbed()
            }

        rootController.embedChild(styleColorViewController)

        styleColorViewController.view.pinAllEdges(to: rootController.view)
        styleColorViewController.colorView.containerView.layoutUsing.anchors {
            $0.width.equal(to: 260)
            $0.height.equal(to: 176)
            $0.centerX.equal(to: rootController.view.centerXAnchor, constant: 10)
            $0.bottom.equal(to: rootController.view.bottomAnchor, constant: -50)
        }
        UISelectionFeedbackGenerator().selectionChanged()
    }

    func showMarkupBottomSheet(
        selectedBlockIds: [BlockId],
        viewDidClose: @escaping () -> Void
    ) {
        guard let controller = viewController,
            let rootController = rootController else { return }
        guard let controller = controller as? EditorPageController else {
            anytypeAssertionFailure("Not supported type of controller: \(controller)", domain: .editorPage)
            return
        }
        
        let viewModel = MarkupViewModel(
            document: document,
            blockIds: selectedBlockIds,
            actionHandler: controller.viewModel.actionHandler,
            linkToObjectCoordinator: linkToObjectCoordinator
        )
        let viewController = MarkupsViewController(
            viewModel: viewModel,
            viewDidClose: viewDidClose
        )

        viewModel.view = viewController

        rootController.embedChild(viewController)

        viewController.view.pinAllEdges(to: rootController.view)
        viewController.containerShadowView.layoutUsing.anchors {
            $0.width.equal(to: 240)
            $0.height.equal(to: 158)
            $0.centerX.equal(to: rootController.view.centerXAnchor, constant: 10)
            $0.bottom.equal(to: rootController.view.bottomAnchor, constant: -50)
        }
    }
    
    // MARK: - Private
    
    private func presentOverCurrentContextSwuftUIView<Content: View>(view: Content, model: Dismissible) {
        let controller = UIHostingController(rootView: view)
        controller.modalPresentationStyle = .overCurrentContext
        
        controller.view.backgroundColor = .clear
        controller.view.isOpaque = false
        
        model.onDismiss = { [weak controller] in
            controller?.dismiss(animated: false)
        }
        
        navigationContext.present(controller, animated: false)
    }
    
    private func showURLInputViewController(
        url: AnytypeURL? = nil,
        completion: @escaping(AnytypeURL?) -> Void
    ) {
        let controller = URLInputViewController(url: url, didSetURL: completion)
        controller.modalPresentationStyle = .overCurrentContext
        navigationContext.present(controller, animated: false)
    }
    
    private func showTypesSearch(
        title: String,
        selectedObjectId: BlockId?,
        showBookmark: Bool,
        showSet: Bool,
        onSelect: @escaping (BlockId) -> ()
    ) {
        let view = NewSearchModuleAssembly.objectTypeSearchModule(
            title: title,
            selectedObjectId: selectedObjectId,
            excludedObjectTypeId: document.details?.type,
            showBookmark: showBookmark,
            showSet: showSet
        ) { [weak self] id in
            self?.navigationContext.dismissTopPresented()
            onSelect(id)
        }
        
        navigationContext.presentSwiftUIView(view: view)
    }
}

extension EditorRouter: AttachmentRouterProtocol {
    func openImage(_ imageContext: FilePreviewContext) {
        let previewController = AnytypePreviewController(with: [imageContext.file], sourceView: imageContext.sourceView, onContentChanged: imageContext.onDidEditFile)

        navigationContext.present(previewController) { [weak previewController] in
            previewController?.didFinishTransition = true
        }
    }
}

// MARK: - Relations
extension EditorRouter {
    func showRelationValueEditingView(key: String, source: RelationSource) {
        let relation = document.parsedRelations.all.first { $0.key == key }
        guard let relation = relation else { return }
        
        showRelationValueEditingView(objectId: document.objectId, source: source, relation: relation)
    }
    
    func showRelationValueEditingView(objectId: BlockId, source: RelationSource, relation: Relation) {
        relationValueCoordinator.startFlow(objectId: objectId, source: source, relation: relation, output: self)
    }

    func showAddNewRelationView(onSelect: ((RelationDetails, _ isNew: Bool) -> Void)?) {
        addNewRelationCoordinator.showAddNewRelationView(onCompletion: onSelect)
    }
}

extension EditorRouter: RelationValueCoordinatorOutput {
    func openObject(pageId: BlockId, viewType: EditorViewType) {
        navigationContext.dismissAllPresented()
        showPage(data: EditorScreenData(pageId: pageId, type: viewType))
    }
}

// MARK: - Set

extension EditorRouter {
    
    func showViewPicker(
        setModel: EditorSetViewModel,
        dataviewService: DataviewServiceProtocol,
        showViewTypes: @escaping RoutingAction<DataviewView?>)
    {
        let viewModel = EditorSetViewPickerViewModel(
            setModel: setModel,
            dataviewService: dataviewService,
            showViewTypes: showViewTypes
        )
        let vc = UIHostingController(
            rootView: EditorSetViewPicker(viewModel: viewModel)
        )
        presentSheet(vc)
    }

    func showCreateObject(pageId: BlockId) {
        let relationService = RelationsService(objectId: pageId)
        let viewModel = CreateObjectViewModel(relationService: relationService) { [weak self] in
            self?.navigationContext.dismissTopPresented()
            self?.showPage(data: EditorScreenData(pageId: pageId, type: .page))
        } closeAction: { [weak self] in
            self?.navigationContext.dismissTopPresented()
        }
        
        showCreateObject(with: viewModel)
    }
    
    func showCreateBookmarkObject() {
        let viewModel = CreateBookmarkViewModel(
            bookmarkService: ServiceLocator.shared.bookmarkService(),
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
        
        showCreateObject(with: viewModel)
    }
    
    func showRelationSearch(relationsDetails: [RelationDetails], onSelect: @escaping (RelationDetails) -> Void) {
        let vc = UIHostingController(
            rootView: NewSearchModuleAssembly.setSortsSearchModule(
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
    
    func showSetSettings(setModel: EditorSetViewModel) {
        guard let currentSetSettingsPopup = currentSetSettingsPopup else {
            showSetSettingsPopup(setModel: setModel)
            return
        }
        currentSetSettingsPopup.dismiss(animated: false) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.showSetSettingsPopup(setModel: setModel)
            }
        }
    }
    
    func dismissSetSettingsIfNeeded() {
        currentSetSettingsPopup?.dismiss(animated: false)
    }
    
    func showViewSettings(setModel: EditorSetViewModel, dataviewService: DataviewServiceProtocol) {
        let viewModel = EditorSetViewSettingsViewModel(
            setModel: setModel,
            service: dataviewService,
            router: self
        )
        let view = EditorSetViewSettingsView(
            setModel: setModel,
            model: viewModel
        )
        navigationContext.presentSwiftUIView(view: view)
    }
    
    func showSorts(setModel: EditorSetViewModel, dataviewService: DataviewServiceProtocol) {
        let viewModel = SetSortsListViewModel(
            setModel: setModel,
            service: dataviewService,
            router: self
        )
        let vc = UIHostingController(
            rootView: SetSortsListView(viewModel: viewModel)
        )
        presentSheet(vc)
    }
    
    func showFilters(setModel: EditorSetViewModel, dataviewService: DataviewServiceProtocol) {
        let viewModel = SetFiltersListViewModel(
            setModel: setModel,
            dataviewService: dataviewService,
            router: self
        )
        let vc = UIHostingController(
            rootView: SetFiltersListView(viewModel: viewModel)
        )
        presentSheet(vc)
    }
    
    private func showCreateObject(with viewModel: CreateObjectViewModelProtocol) {
        guard let viewController = viewController else { return }
        
        let view = CreateObjectView(viewModel: viewModel)
        let fpc = AnytypePopup(contentView: view,
                               floatingPanelStyle: true,
                               configuration: .init(isGrabberVisible: true, dismissOnBackdropView: true ))

        viewController.topPresentedController.present(fpc, animated: true) {
            _ = view.becomeFirstResponder()
        }
    }
    
    private func showSetSettingsPopup(setModel: EditorSetViewModel) {
        let popup = AnytypePopup(
            viewModel: EditorSetSettingsViewModel(setModel: setModel),
            floatingPanelStyle: true,
            configuration: .init(
                isGrabberVisible: true,
                dismissOnBackdropView: false,
                skipThroughGestures: true
            )
        )
        currentSetSettingsPopup = popup
        presentFullscreen(popup)
    }
    
    func showFilterSearch(
        filter: SetFilter,
        onApply: @escaping (SetFilter) -> Void
    ) {
        let viewModel = SetFiltersSelectionViewModel(
            filter: filter,
            router: self,
            onApply: { [weak self] filter in
                onApply(filter)
                self?.navigationContext.dismissTopPresented()
            }
        )
        presentFullscreen(
            AnytypePopup(
                viewModel: viewModel
            )
        )
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
    
    func showCovers(setModel: EditorSetViewModel, onSelect: @escaping (String) -> Void) {
        let viewModel = SetViewSettingsImagePreviewViewModel(
            setModel: setModel,
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
        selectedRelationId: String,
        relations: [RelationDetails],
        onSelect: @escaping (String) -> Void
    ) {
        let view = CheckPopupView(
            viewModel: SetViewSettingsGroupByViewModel(
                selectedRelationId: selectedRelationId,
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
    
    func showKanbanColumnSettings() {
        let popup = AnytypePopup(
            viewModel: SetKanbanColumnSettingsViewModel(
                hideColumn: false,
                selectedColor: nil,
                onApplyTap: { [weak self] _, _ in
                    self?.navigationContext.dismissTopPresented()
                }
            ),
            configuration: .init(
                isGrabberVisible: true,
                dismissOnBackdropView: true
            )
        )
        presentFullscreen(popup)
    }
}

extension EditorRouter: ObjectSettingsModuleDelegate {
    func didCreateLinkToItself(in objectId: BlockId) {
        toastPresenter.showObjectCompositeAlert(p1: Loc.Editor.Toast.getStartedLinkedTo, objectId: objectId) { [weak self] in
            self?.showPage(data: .init(pageId: objectId, type: .page))
        }
    }
}


// MARK: - UIPopoverPresentationControllerDelegate

extension EditorRouter: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {

    }

    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return true
    }
}
