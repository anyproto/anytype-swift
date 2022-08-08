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
    private let editorAssembly: EditorAssembly
    private let templatesCoordinator: TemplatesCoordinator
    private let urlOpener: URLOpenerProtocol
    private let relationValueCoordinator: RelationValueCoordinatorProtocol
    private weak var currentSetSettingsPopup: AnytypePopup?
    
    init(
        rootController: EditorBrowserController?,
        viewController: UIViewController,
        document: BaseDocumentProtocol,
        assembly: EditorAssembly,
        templatesCoordinator: TemplatesCoordinator,
        urlOpener: URLOpenerProtocol,
        relationValueCoordinator: RelationValueCoordinatorProtocol
    ) {
        self.rootController = rootController
        self.viewController = viewController
        self.document = document
        self.editorAssembly = assembly
        self.fileCoordinator = FileDownloadingCoordinator(viewController: viewController)
        self.addNewRelationCoordinator = AddNewRelationCoordinator(document: document, viewController: viewController)
        self.templatesCoordinator = templatesCoordinator
        self.urlOpener = urlOpener
        self.relationValueCoordinator = relationValueCoordinator
    }

    func showPage(data: EditorScreenData) {
        if let details = ObjectDetailsStorage.shared.get(id: data.pageId) {
            guard ObjectTypeProvider.shared.isSupported(typeUrl: details.type) else {
                showUnsupportedTypeAlert(typeUrl: details.type)
                return
            }
        }
        
        let controller = editorAssembly.buildEditorController(
            browser: rootController,
            data: data,
            editorBrowserViewInput: rootController
        )
        viewController?.navigationController?.pushViewController(controller, animated: true)
    }

    func showAlert(alertModel: AlertModel) {
        let alertController = AlertsFactory.alertController(from: alertModel)
        viewController?.present(alertController, animated: true, completion: nil)
    }
    
    private func showUnsupportedTypeAlert(typeUrl: String) {
        let typeName = ObjectTypeProvider.shared.objectType(url: typeUrl)?.name ?? Loc.unknown
        
        AlertHelper.showToast(
            title: "Not supported type \"\(typeName)\"",
            message: "You can open it via desktop"
        )
    }

    func showLinkContextualMenu(inputParameters: TextBlockURLInputParameters) {
        let contextualMenuView = EditorContextualMenuView(
            options: [.dismiss, .createBookmark],
            optionTapHandler: { [weak rootController] option in
                rootController?.presentedViewController?.dismiss(animated: false, completion: nil)
                inputParameters.optionHandler(option)
            }
        )

        let hostViewController = UIHostingController(rootView: contextualMenuView)
        hostViewController.modalPresentationStyle = .popover

        hostViewController.preferredContentSize = hostViewController
            .sizeThatFits(
                in: .init(
                    width: CGFloat.greatestFiniteMagnitude,
                    height: CGFloat.greatestFiniteMagnitude
                )
            )

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
    
    func showBookmarkBar(completion: @escaping (URL) -> ()) {
        showURLInputViewController { url in
            guard let url = url else { return }
            completion(url)
        }
    }
    
    func showLinkMarkup(url: URL?, completion: @escaping (URL?) -> Void) {
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
            showMarkupMenu: { [weak controller, weak rootController, unowned document] styleView, viewDidClose in
                guard let controller = controller else { return }
                guard let rootController = rootController else { return }
                guard let info = document.infoContainer.get(id: information.id) else { return }

                BottomSheetsFactory.showMarkupBottomSheet(
                    parentViewController: rootController,
                    styleView: styleView,
                    selectedMarkups: AttributeState.markupAttributes(from: [info]),
                    selectedHorizontalAlignment: AttributeState.alignmentAttributes(from: [info]),
                    onMarkupAction: { [unowned controller] action in
                        switch action {
                        case let .selectAlignment(alignment):
                            controller.viewModel.actionHandler.setAlignment(alignment, blockIds: [info.id])
                        case let .toggleMarkup(markup):
                            controller.viewModel.actionHandler.toggleWholeBlockMarkup(markup, blockId: info.id)
                        }
                    },
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

        presentSwiftUIView(view: moveToView, model: nil)
    }

    func showLinkToObject(onSelect: @escaping (LinkToObjectSearchViewModel.SearchKind) -> ()) {
        let viewModel = LinkToObjectSearchViewModel { data in
            onSelect(data.searchKind)
        }
        let linkToView = SearchView(title: Loc.linkTo, context: .menuSearch, viewModel: viewModel)

        presentSwiftUIView(view: linkToView, model: viewModel)
    }

    func showLinkTo(onSelect: @escaping (BlockId) -> ()) {
        let viewModel = ObjectSearchViewModel { data in
            onSelect(data.blockId)
        }
        let linkToView = SearchView(title: Loc.linkTo, context: .menuSearch, viewModel: viewModel)
        
        presentSwiftUIView(view: linkToView, model: viewModel)
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

        presentSwiftUIView(view: iconPicker, model: nil)
    }
    
    func showSearch(onSelect: @escaping (EditorScreenData) -> ()) {
        let viewModel = ObjectSearchViewModel { data in
            onSelect(EditorScreenData(pageId: data.blockId, type: data.viewType))
        }
        let searchView = SearchView(title: nil, context: .menuSearch, viewModel: viewModel)
        
        presentSwiftUIView(view: searchView, model: viewModel)
    }
    
    func showTypesSearch(onSelect: @escaping (BlockId) -> ()) {
        let view = NewSearchModuleAssembly.objectTypeSearchModule(
            title: Loc.changeType,
            excludedObjectTypeId: document.details?.type
        ) { [weak self] id in
            onSelect(id)
            
            self?.viewController?.topPresentedController.dismiss(animated: true)
        }
        
        let controller = UIHostingController(rootView: view)
        viewController?.topPresentedController.present(controller, animated: true)
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
        guard let viewController = viewController else { return }

        let toastPresenter = ToastPresenter(rootViewController: viewController)
        let undoRedoView = UndoRedoView(
            viewModel: .init(objectId: document.objectId, toastPresenter: toastPresenter)
        )
        let popupViewController = AnytypePopup(
            contentView: undoRedoView,
            floatingPanelStyle: true,
            configuration: .init(isGrabberVisible: false, dismissOnBackdropView: true)
        )
        popupViewController.backdropView.backgroundColor = .clear

        self.viewController?.dismissAndPresent(viewController: popupViewController)
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
        selectedMarkups: [MarkupType : AttributeState],
        selectedHorizontalAlignment: [LayoutAlignment : AttributeState],
        onMarkupAction: @escaping (MarkupViewModelAction) -> Void,
        viewDidClose: @escaping () -> Void
    ) {
        guard let rootController = rootController else { return }

        let viewModel = MarkupViewModel(
            selectedMarkups: selectedMarkups,
            selectedHorizontalAlignment: selectedHorizontalAlignment,
            onMarkupAction: onMarkupAction
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

    private func presentSwiftUIView<Content: View>(view: Content, model: Dismissible?) {
        guard let viewController = viewController else { return }
        
        let controller = UIHostingController(rootView: view)
        model?.onDismiss = { [weak controller] in controller?.dismiss(animated: true) }
        viewController.topPresentedController.present(controller, animated: true)
    }
    
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
        url: URL? = nil,
        completion: @escaping(URL?) -> Void
    ) {
        let controller = URLInputViewController(url: url, didSetURL: completion)
        controller.modalPresentationStyle = .overCurrentContext
        viewController?.present(controller, animated: false)
    }
}

extension EditorRouter: AttachmentRouterProtocol {
    func openImage(_ imageContext: BlockImageViewModel.ImageOpeningContext) {
        let viewModel = GalleryViewModel(
            items: [.init(imageSource: imageContext.image, previewImage: imageContext.imageView.image)],
            initialImageDisplayIndex: 0
        )
        let galleryViewController = GalleryViewController(
            viewModel: viewModel,
            initialImageView: imageContext.imageView
        )

        viewController?.present(galleryViewController, animated: true, completion: nil)
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
    
    func showViewPicker(setModel: EditorSetViewModel) {
        let viewModel = EditorSetViewPickerViewModel(setModel: setModel)
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
            bookmarkService: BookmarkService(),
            closeAction: { [weak self] withError in
                self?.viewController?.topPresentedController.dismiss(animated: true, completion: {
                    guard withError else { return }
                    AlertHelper.showToast(
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
            rootView: EditorSetViewSettingsView()
                .environmentObject(viewModel)
                .environmentObject(setModel)
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
            rootView: SetSortsListView()
                .environmentObject(viewModel)
                .environmentObject(setModel)
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
            rootView: SetFiltersListView()
                .environmentObject(viewModel)
                .environmentObject(setModel)
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
            viewModel: EditorSetViewSettingsCardSizeViewModel(
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
