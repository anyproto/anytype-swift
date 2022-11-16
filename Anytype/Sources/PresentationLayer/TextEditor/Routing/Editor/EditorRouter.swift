import UIKit
import BlocksModels
import SafariServices
import SwiftUI
import FloatingPanel
import AnytypeCore

final class EditorRouter: NSObject, EditorRouterProtocol {
    private weak var rootController: EditorBrowserController?
    private weak var viewController: UIViewController?
    private let fileCoordinator: FileDownloadingCoordinator
    private let addNewRelationCoordinator: AddNewRelationCoordinator
    private let document: BaseDocumentProtocol
    private let settingAssembly = ObjectSettingAssembly()
    private let templatesCoordinator: TemplatesCoordinator
    private let urlOpener: URLOpenerProtocol
    private let relationValueCoordinator: RelationValueCoordinatorProtocol
    private weak var currentSetSettingsPopup: AnytypePopup?
    private let editorPageCoordinator: EditorPageCoordinatorProtocol
    private let linkToObjectCoordinator: LinkToObjectCoordinatorProtocol
    private let undoRedoModuleAssembly: UndoRedoModuleAssemblyProtocol
    private let alertHelper: AlertHelper
    
    init(
        rootController: EditorBrowserController?,
        viewController: UIViewController,
        document: BaseDocumentProtocol,
        templatesCoordinator: TemplatesCoordinator,
        urlOpener: URLOpenerProtocol,
        relationValueCoordinator: RelationValueCoordinatorProtocol,
        editorPageCoordinator: EditorPageCoordinatorProtocol,
        linkToObjectCoordinator: LinkToObjectCoordinatorProtocol,
        undoRedoModuleAssembly: UndoRedoModuleAssemblyProtocol,
        alertHelper: AlertHelper
    ) {
        self.rootController = rootController
        self.viewController = viewController
        self.document = document
        self.fileCoordinator = FileDownloadingCoordinator(viewController: viewController)
        self.addNewRelationCoordinator = AddNewRelationCoordinator(document: document, viewController: viewController)
        self.templatesCoordinator = templatesCoordinator
        self.urlOpener = urlOpener
        self.relationValueCoordinator = relationValueCoordinator
        self.editorPageCoordinator = editorPageCoordinator
        self.linkToObjectCoordinator = linkToObjectCoordinator
        self.undoRedoModuleAssembly = undoRedoModuleAssembly
        self.alertHelper = alertHelper
    }

    func showPage(data: EditorScreenData) {
        editorPageCoordinator.startFlow(data: data, replaceCurrentPage: false)
    }

    func replaceCurrentPage(with data: EditorScreenData) {
        editorPageCoordinator.startFlow(data: data, replaceCurrentPage: true)
    }

    func showAlert(alertModel: AlertModel) {
        let alertController = AlertsFactory.alertController(from: alertModel)
        viewController?.present(alertController, animated: true, completion: nil)
    }

    func showLinkContextualMenu(inputParameters: TextBlockURLInputParameters) {
        let contextualMenuView = EditorContextualMenuView(
            options: [.pasteAsLink, .createBookmark, .pasteAsText],
            optionTapHandler: { [weak rootController] option in
                rootController?.presentedViewController?.dismiss(animated: false, completion: nil)
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

            rootController?.present(hostViewController, animated: true, completion: nil)
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
        viewController?.present(vc, animated: true, completion: nil)
    }
    
    func showImagePicker(contentType: MediaPickerContentType, onSelect: @escaping (NSItemProvider?) -> Void) {
        let vc = UIHostingController(
            rootView: MediaPickerView(
                contentType: contentType,
                onSelect: onSelect
            )
        )
        viewController?.present(vc, animated: true, completion: nil)
    }
    
    func saveFile(fileURL: URL, type: FileContentType) {
        fileCoordinator.downloadFileAt(fileURL, withType: type)
    }
    
    func showCodeLanguageView(languages: [CodeLanguage], completion: @escaping (CodeLanguage) -> Void) {
        let searchListViewController = SearchListViewController(items: languages, completion: completion)
        searchListViewController.modalPresentationStyle = .pageSheet
        viewController?.present(searchListViewController, animated: true)
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
        
        let moveToView = NewSearchModuleAssembly.moveToObjectSearchModule(
            title: Loc.moveTo,
            excludedObjectIds: [document.objectId]
        ) { [weak self] blockId in
            onSelect(blockId)
            self?.viewController?.topPresentedController.dismiss(animated: true)
        }

        viewController?.topPresentedController.presentSwiftUIView(view: moveToView, model: nil)
    }

    func showLinkTo(onSelect: @escaping (BlockId, _ typeUrl: String) -> ()) {
        let viewModel = ObjectSearchViewModel { data in
            onSelect(data.blockId, data.typeUrl)
        }
        let linkToView = SearchView(title: Loc.linkTo, context: .menuSearch, viewModel: viewModel)
        
        viewController?.topPresentedController.presentSwiftUIView(view: linkToView, model: viewModel)
    }

    func showTextIconPicker(contextId: BlockId, objectId: BlockId) {
        let viewModel = TextIconPickerViewModel(
            fileService: FileActionsService(),
            textService: TextService(),
            contextId: contextId,
            objectId: objectId
        )

        let iconPicker = ObjectBasicIconPicker(viewModel: viewModel) { [weak rootController] in
            rootController?.dismiss(animated: true, completion: nil)
        }

        viewController?.topPresentedController.presentSwiftUIView(view: iconPicker, model: nil)
    }
    
    func showSearch(onSelect: @escaping (EditorScreenData) -> ()) {
        let viewModel = ObjectSearchViewModel { data in
            onSelect(EditorScreenData(pageId: data.blockId, type: data.viewType))
        }
        let searchView = SearchView(title: nil, context: .menuSearch, viewModel: viewModel)
        
        viewController?.topPresentedController.presentSwiftUIView(view: searchView, model: viewModel)
    }
    
    func showTypes(selectedObjectId: BlockId?, onSelect: @escaping (BlockId) -> ()) {
        showTypesSearch(title: Loc.changeType, selectedObjectId: selectedObjectId, showBookmark: false, onSelect: onSelect)
    }
    
    func showSources(selectedObjectId: BlockId?, onSelect: @escaping (BlockId) -> ()) {
        showTypesSearch(title: Loc.Set.SourceType.selectSource, selectedObjectId: selectedObjectId, showBookmark: true, onSelect: onSelect)
    }
    
    func showWaitingView(text: String) {
        let popup = PopupViewBuilder.createWaitingPopup(text: text)
        viewController?.topPresentedController.present(popup, animated: true, completion: nil)
    }

    func hideWaitingView() {
        viewController?.topPresentedController.dismiss(animated: true, completion: nil)
    }
    
    func goBack() {
        rootController?.pop()
    }
    
    func presentSheet(_ vc: UIViewController) {
        if #available(iOS 15.0, *) {
            if let sheet = vc.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                sheet.selectedDetentIdentifier = .medium
            }
        }
        
        viewController?.topPresentedController.present(vc, animated: true)
    }
    
    func presentFullscreen(_ vc: UIViewController) {
        rootController?.topPresentedController.present(vc, animated: true)
    }

    func presentUndoRedo() {
        let moduleViewController = undoRedoModuleAssembly.make(document: document)
        self.viewController?.dismissAndPresent(viewController: moduleViewController)
    }
    
    func setNavigationViewHidden(_ isHidden: Bool, animated: Bool) {
        rootController?.setNavigationViewHidden(isHidden, animated: animated)
    }

    func showObjectPreview(blockLinkAppearance: BlockLink.Appearance, onSelect: @escaping (BlockLink.Appearance) -> Void) {
        let previewModel = ObjectPreviewModel(linkApperance: blockLinkAppearance)
        let router = ObjectPreviewRouter(viewController: viewController)
        let viewModel = ObjectPreviewViewModel(objectPreviewModel: previewModel,
                                               router: router,
                                               onSelect: onSelect)
        let contentView = ObjectPreviewView(viewModel: viewModel)
        let popup = AnytypePopup(contentView: contentView)

        viewController?.topPresentedController.present(popup, animated: true, completion: nil)

    }

    func showTemplatesAvailabilityPopupIfNeeded(
        document: BaseDocumentProtocol,
        templatesTypeURL: ObjectTypeUrl
    ) {
        templatesCoordinator.showTemplatesAvailabilityPopupIfNeeded(
            document: document,
            templatesTypeURL: .dynamic(templatesTypeURL.rawValue)
        )
    }
    
    // MARK: - Settings
    func showSettings() {
        let popup = settingAssembly.settingsPopup(document: document, router: self)
        viewController?.topPresentedController.present(popup, animated: true, completion: nil)
    }
    
    func showCoverPicker() {
        let picker = settingAssembly.coverPicker(document: document)
        viewController?.topPresentedController.present(picker, animated: true)
    }
    
    func showIconPicker() {
        let controller = settingAssembly.iconPicker(document: document)
        viewController?.topPresentedController.present(controller, animated: true)
    }
    
    func showLayoutPicker() {
        let popup = settingAssembly.layoutPicker(document: document)
        viewController?.topPresentedController.present(popup, animated: true, completion: nil)
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
        guard let viewController = rootController else { return }
        
        let controller = UIHostingController(rootView: view)
        controller.modalPresentationStyle = .overCurrentContext
        
        controller.view.backgroundColor = .clear
        controller.view.isOpaque = false
        
        model.onDismiss = { [weak controller] in
            controller?.dismiss(animated: false)
        }
        
        viewController.topPresentedController.present(controller, animated: false)
    }
    
    private func showURLInputViewController(
        url: AnytypeURL? = nil,
        completion: @escaping(AnytypeURL?) -> Void
    ) {
        let controller = URLInputViewController(url: url, didSetURL: completion)
        controller.modalPresentationStyle = .overCurrentContext
        viewController?.present(controller, animated: false)
    }
    
    private func showTypesSearch(title: String, selectedObjectId: BlockId?, showBookmark: Bool, onSelect: @escaping (BlockId) -> ()) {
        let view = NewSearchModuleAssembly.objectTypeSearchModule(
            title: title,
            selectedObjectId: selectedObjectId,
            excludedObjectTypeId: document.details?.type,
            showBookmark: showBookmark
        ) { [weak self] id in
            onSelect(id)
            
            self?.viewController?.topPresentedController.dismiss(animated: true)
        }
        
        let controller = UIHostingController(rootView: view)
        viewController?.topPresentedController.present(controller, animated: true)
    }
}

extension EditorRouter: AttachmentRouterProtocol {
    func openImage(_ imageContext: FilePreviewContext) {
        let previewController = AnytypePreviewController(with: [imageContext.file], sourceView: imageContext.sourceView, onContentChanged: imageContext.onDidEditFile)

        rootController?.present(previewController, animated: true) { [weak previewController] in
            previewController?.didFinishTransition = true
        }
    }
}

// MARK: - Relations
extension EditorRouter {
    func showRelationValueEditingView(key: String, source: RelationSource) {
        let relation = document.parsedRelations.all.first { $0.id == key }
        guard let relation = relation else { return }
        
        showRelationValueEditingView(objectId: document.objectId, source: source, relation: relation)
    }
    
    func showRelationValueEditingView(objectId: BlockId, source: RelationSource, relation: Relation) {
        relationValueCoordinator.startFlow(objectId: objectId, source: source, relation: relation, output: self)
    }

    func showAddNewRelationView(onSelect: ((RelationMetadata, _ isNew: Bool) -> Void)?) {
        addNewRelationCoordinator.showAddNewRelationView(onCompletion: onSelect)
    }
}

extension EditorRouter: RelationValueCoordinatorOutput {
    func openObject(pageId: BlockId, viewType: EditorViewType) {
        viewController?.dismiss(animated: true)
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
            self?.viewController?.topPresentedController.dismiss(animated: true)
            self?.showPage(data: EditorScreenData(pageId: pageId, type: .page))
        } closeAction: { [weak self] in
            self?.viewController?.topPresentedController.dismiss(animated: true)
        }
        
        showCreateObject(with: viewModel)
    }
    
    func showCreateBookmarkObject() {
        let viewModel = CreateBookmarkViewModel(
            bookmarkService: ServiceLocator.shared.bookmarkService(),
            closeAction: { [weak self] withError in
                self?.viewController?.topPresentedController.dismiss(animated: true, completion: {
                    guard withError else { return }
                    self?.alertHelper.showToast(
                        title: Loc.Set.Bookmark.Error.title,
                        message: Loc.Set.Bookmark.Error.message
                    )
                })
            }
        )
        
        showCreateObject(with: viewModel)
    }
    
    func showRelationSearch(relations: [RelationMetadata], onSelect: @escaping (String) -> Void) {
        let vc = UIHostingController(
            rootView: NewSearchModuleAssembly.setSortsSearchModule(
                relations: relations,
                onSelect: { [weak self] key in
                    self?.viewController?.topPresentedController.dismiss(animated: false) {
                        onSelect(key)
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
        viewController?.topPresentedController.present(vc, animated: true)
    }
    
    func showViewTypes(
        dataView: BlockDataview,
        activeView: DataviewView?,
        dataviewService: DataviewServiceProtocol)
    {
        let viewModel = SetViewTypesPickerViewModel(
            dataView: dataView,
            activeView: activeView,
            dataviewService: dataviewService
        )
        let vc = UIHostingController(
            rootView: SetViewTypesPicker(viewModel: viewModel)
        )
        presentSheet(vc)
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
        let vc = UIHostingController(
            rootView: EditorSetViewSettingsView(
                setModel: setModel,
                model: viewModel
            )
        )
        viewController?.topPresentedController.present(vc, animated: true)
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
                self?.viewController?.topPresentedController.dismiss(animated: true)
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
        relations: [RelationMetadata],
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
