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
    private lazy var relationEditingViewModelBuilder = RelationEditingViewModelBuilder(delegate: self)
    
    init(
        rootController: EditorBrowserController?,
        viewController: UIViewController,
        document: BaseDocumentProtocol,
        assembly: EditorAssembly,
        templatesCoordinator: TemplatesCoordinator
    ) {
        self.rootController = rootController
        self.viewController = viewController
        self.document = document
        self.editorAssembly = assembly
        self.fileCoordinator = FileDownloadingCoordinator(viewController: viewController)
        self.addNewRelationCoordinator = AddNewRelationCoordinator(document: document, viewController: viewController)
        self.templatesCoordinator = templatesCoordinator
    }

    func showPage(data: EditorScreenData) {
        if let details = ObjectDetailsStorage.shared.get(id: data.pageId) {
            guard ObjectTypeProvider.shared.isSupported(typeUrl: details.type) else {
                showUnsupportedTypeAlert(typeUrl: details.type)
                return
            }
        }
        
        let controller = editorAssembly.buildEditorController(data: data, editorBrowserViewInput: rootController)
        viewController?.navigationController?.pushViewController(controller, animated: true)
    }

    func showAlert(alertModel: AlertModel) {
        let alertController = AlertsFactory.alertController(from: alertModel)
        viewController?.present(alertController, animated: true, completion: nil)
    }
    
    private func showUnsupportedTypeAlert(typeUrl: String) {
        let typeName = ObjectTypeProvider.shared.objectType(url: typeUrl)?.name ?? "Unknown".localized
        
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
        let url = url.urlByAddingHttpIfSchemeIsEmpty()
        if url.containsHttpProtocol {
            let safariController = SFSafariViewController(url: url)
            viewController?.topPresentedController.present(safariController, animated: true)
            return
        }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
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
    
    func showStyleMenu(information: BlockInformation) {
        guard let controller = viewController,
              let rootController = rootController,
              let info = document.infoContainer.get(id: information.id) else { return }
        guard let controller = controller as? EditorPageController else {
            anytypeAssertionFailure("Not supported type of controller: \(controller)", domain: .editorPage)
            return
        }

        controller.view.endEditing(true)

        let didShow: (FloatingPanelController) -> Void  = { fpc in
            // Initialy keyboard is shown and we open context menu, so keyboard moves away
            // Then we select "Style" item from menu and display bottom sheet
            // Then system call "becomeFirstResponder" on UITextView which was firstResponder
            // and keyboard covers bottom sheet, this method helps us to unsure bottom sheet is visible
            if fpc.state == FloatingPanelState.full {
                controller.view.endEditing(true)
            }
            controller.adjustContentOffset(fpc: fpc)
        }

        BottomSheetsFactory.createStyleBottomSheet(
            parentViewController: rootController,
            delegate: controller,
            info: info,
            actionHandler: controller.viewModel.actionHandler,
            didShow: didShow,
            showMarkupMenu: { [weak controller, weak rootController] styleView, viewDidClose in
                guard let controller = controller else { return }
                guard let rootController = rootController else { return }

                BottomSheetsFactory.showMarkupBottomSheet(
                    parentViewController: rootController,
                    styleView: styleView,
                    blockInformation: info,
                    viewModel: controller.viewModel.wholeBlockMarkupViewModel,
                    viewDidClose: viewDidClose
                )
            }
        )
        controller.selectBlock(blockId: information.id)
    }
    
    func showMoveTo(onSelect: @escaping (BlockId) -> ()) {
        
        let moveToView = NewSearchModuleAssembly.moveToObjectSearchModule(
            title: "Move to".localized,
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
        let linkToView = SearchView(title: "Link to".localized, context: .menuSearch, viewModel: viewModel)

        presentSwiftUIView(view: linkToView, model: viewModel)
    }

    func showLinkTo(onSelect: @escaping (BlockId) -> ()) {
        let viewModel = ObjectSearchViewModel { data in
            onSelect(data.blockId)
        }
        let linkToView = SearchView(title: "Link to".localized, context: .menuSearch, viewModel: viewModel)
        
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
            title: "Change type".localized,
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
        templatesTypeURL: ObjectTemplateType
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

extension EditorRouter: TextRelationActionButtonViewModelDelegate {
    
    func canOpenUrl(_ url: URL) -> Bool {
        UIApplication.shared.canOpenURL(url.urlByAddingHttpIfSchemeIsEmpty())
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
        guard relation.isEditable else { return }
        
        if case .checkbox(let checkbox) = relation {
            let relationsService = RelationsService(objectId: objectId)
            relationsService.updateRelation(relationKey: checkbox.id, value: (!checkbox.value).protobufValue)
            return
        }
        
        guard let viewController = viewController else { return }
        
        let contentViewModel = relationEditingViewModelBuilder
            .buildViewModel(source: source, objectId: objectId, relation: relation)
        guard let contentViewModel = contentViewModel else { return }
        
        let fpc = AnytypePopup(viewModel: contentViewModel)
        viewController.topPresentedController.present(fpc, animated: true, completion: nil)
    }

    func showAddNewRelationView(onSelect: ((RelationMetadata, _ isNew: Bool) -> Void)?) {
        addNewRelationCoordinator.showAddNewRelationView(onCompletion: onSelect)
    }
}

// MARK: - Set

extension EditorRouter {

    func showCreateObject(pageId: BlockId) {
        guard let viewController = viewController else { return }

        let relationService = RelationsService(objectId: pageId)
        let viewModel = CreateObjectViewModel(relationService: relationService) { [weak self] in
            self?.viewController?.topPresentedController.dismiss(animated: true)
            self?.showPage(data: EditorScreenData(pageId: pageId, type: .page))
        } closeAction: { [weak self] in
            self?.viewController?.topPresentedController.dismiss(animated: true)
        }
        
        let view = CreateObjectView(viewModel: viewModel)
        let fpc = AnytypePopup(contentView: view,
                               floatingPanelStyle: true,
                               configuration: .init(isGrabberVisible: true, dismissOnBackdropView: true ))

        viewController.topPresentedController.present(fpc, animated: true) {
            view.becomeFirstResponder()
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
