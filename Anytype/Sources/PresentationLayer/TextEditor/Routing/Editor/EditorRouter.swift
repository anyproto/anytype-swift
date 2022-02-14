import UIKit
import BlocksModels
import SafariServices
import Combine
import SwiftUI
import FloatingPanel
import AnytypeCore

final class EditorRouter: EditorRouterProtocol {
    private weak var rootController: EditorBrowserController?
    private weak var viewController: UIViewController?
    private let fileRouter: FileRouter
    private let document: BaseDocumentProtocol
    private let settingAssembly = ObjectSettingAssembly()
    private let editorAssembly: EditorAssembly
    private lazy var relationEditingViewModelBuilder = RelationEditingViewModelBuilder(delegate: self)
    
    init(
        rootController: EditorBrowserController,
        viewController: UIViewController,
        document: BaseDocumentProtocol,
        assembly: EditorAssembly
    ) {
        self.rootController = rootController
        self.viewController = viewController
        self.document = document
        self.editorAssembly = assembly
        self.fileRouter = FileRouter(fileLoader: FileLoader(), viewController: viewController)
    }

    func showPage(data: EditorScreenData) {
        if let details = ObjectDetailsStorage.shared.get(id: data.pageId)  {
            guard ObjectTypeProvider.isSupported(typeUrl: details.type) else {
                showUnsupportedTypeAlert(typeUrl: details.type)
                return
            }
        }
        
        let controller = editorAssembly.buildEditorController(data: data, editorBrowserViewInput: rootController)
        viewController?.navigationController?.pushViewController(controller, animated: true)
    }
    
    private func showUnsupportedTypeAlert(typeUrl: String) {
        let typeName = ObjectTypeProvider.objectType(url: typeUrl)?.name ?? "Unknown".localized
        
        AlertHelper.showToast(
            title: "Not supported type \"\(typeName)\"",
            message: "You can open it via desktop"
        )
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
    
    func showImagePicker(model: MediaPickerViewModel) {
        let vc = MediaPicker(viewModel: model)
        viewController?.present(vc, animated: true, completion: nil)
    }
    
    func saveFile(fileURL: URL, type: FileContentType) {
        fileRouter.saveFile(fileURL: fileURL, type: type)
    }
    
    func showCodeLanguageView(languages: [CodeLanguage], completion: @escaping (CodeLanguage) -> Void) {
        let searchListViewController = SearchListViewController(items: languages, completion: completion)
        searchListViewController.modalPresentationStyle = .pageSheet
        viewController?.present(searchListViewController, animated: true)
    }
    
    func showStyleMenu(information: BlockInformation) {
        guard let controller = viewController,
              let rootController = rootController,
              let blockModel = document.blocksContainer.model(id: information.id) else { return }
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
            blockModel: blockModel,
            actionHandler: controller.viewModel.actionHandler,
            didShow: didShow,
            showMarkupMenu: { [weak controller, weak rootController] styleView, viewDidClose in
                guard let controller = controller else { return }
                guard let rootController = rootController else { return }

                BottomSheetsFactory.showMarkupBottomSheet(
                    parentViewController: rootController,
                    styleView: styleView,
                    blockInformation: blockModel.information,
                    viewModel: controller.viewModel.wholeBlockMarkupViewModel,
                    viewDidClose: viewDidClose
                )
            }
        )
        controller.selectBlock(blockId: information.id)
    }
    
    func showSettings(viewModel: ObjectSettingsViewModel) {
        let rootView = ObjectSettingsContainerView(viewModel: viewModel)
        presentOverCurrentContextSwuftUIView(view: rootView, model: rootView.viewModel)
    }
    
    func showCoverPicker(viewModel: ObjectCoverPickerViewModel) {
        guard let viewController = viewController else { return }
        let controller = settingAssembly.coverPicker(viewModel: viewModel)
        viewController.present(controller, animated: true)
    }
    
    func showIconPicker(viewModel: ObjectIconPickerViewModel) {
        guard let viewController = viewController else { return }
        let controller = settingAssembly.iconPicker(viewModel: viewModel)
        viewController.present(controller, animated: true)
    }
    
    func showMoveTo(onSelect: @escaping (BlockId) -> ()) {
        let viewModel = ObjectSearchViewModel(searchKind: .objects) { data in
            onSelect(data.blockId)
        }
        let moveToView = SearchView(title: "Move to".localized, context: .menuSearch, viewModel: viewModel)
        
        presentSwuftUIView(view: moveToView, model: viewModel)
    }

    func showLinkToObject(onSelect: @escaping (LinkToObjectSearchViewModel.SearchKind) -> ()) {
        let viewModel = LinkToObjectSearchViewModel { data in
            onSelect(data.searchKind)
        }
        let linkToView = SearchView(title: "Link to".localized, context: .menuSearch, viewModel: viewModel)

        presentSwuftUIView(view: linkToView, model: viewModel)
    }

    func showLinkTo(onSelect: @escaping (BlockId) -> ()) {
        let viewModel = ObjectSearchViewModel(searchKind: .objects) { data in
            onSelect(data.blockId)
        }
        let linkToView = SearchView(title: "Link to".localized, context: .menuSearch, viewModel: viewModel)
        
        presentSwuftUIView(view: linkToView, model: viewModel)
    }
    
    func showSearch(onSelect: @escaping (EditorScreenData) -> ()) {
        let viewModel = ObjectSearchViewModel(searchKind: .objects) { data in
            onSelect(EditorScreenData(pageId: data.blockId, type: data.viewType))
        }
        let searchView = SearchView(title: nil, context: .menuSearch, viewModel: viewModel)
        
        presentSwuftUIView(view: searchView, model: viewModel)
    }
    
    func showTypesSearch(onSelect: @escaping (BlockId) -> ()) {
        let objectKind: SearchKind = .objectTypes(currentObjectTypeUrl: document.objectDetails?.type ?? "")
        let viewModel = ObjectSearchViewModel(searchKind: objectKind) { data in
            onSelect(data.blockId)
        }
        let searchView = SearchView(title: "Change type".localized, context: .menuSearch, viewModel: viewModel)

        presentSwuftUIView(view: searchView, model: viewModel)
    }
    
    func goBack() {
        rootController?.pop()
    }
    
    func presentSwuftUIView<Content: View>(view: Content, model: Dismissible) {
        guard let viewController = viewController else { return }
        
        let controller = UIHostingController(rootView: view)
        model.onDismiss = { [weak controller] in controller?.dismiss(animated: true) }
        viewController.present(controller, animated: true)
    }
    
    func presentOverCurrentContextSwuftUIView<Content: View>(view: Content, model: Dismissible) {
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
            imageSources: [imageContext.image], initialImageDisplayIndex: 0)
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
        
        let fpc = RelationDetailsViewPopup(viewModel: contentViewModel)
        viewController.topPresentedController.present(fpc, animated: true, completion: nil)
    }

    func showAddNewRelationView(source: RelationSource, onSelect: @escaping (RelationMetadata) -> Void) {
        let relationService = RelationsService(objectId: document.objectId)
        
        let viewModel = SearchNewRelationViewModel(
            source: source,
            relationService: relationService,
            objectRelations: document.parsedRelations,
            onSelect: onSelect)

        let view = SearchNewRelationView(viewModel: viewModel)
        presentSwuftUIView(view: view, model: viewModel)
    }
}
