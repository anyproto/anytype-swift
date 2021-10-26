import UIKit
import BlocksModels
import SafariServices
import Combine
import SwiftUI
import FloatingPanel
import AnytypeCore

protocol EditorRouterProtocol: AnyObject, AttachmentRouterProtocol {
    
    func showPage(with id: BlockId)
    func openUrl(_ url: URL)
    func showBookmarkBar(completion: @escaping (URL) -> ())
    func showLinkMarkup(url: URL?, completion: @escaping (URL?) -> Void)
    
    func showFilePicker(model: Picker.ViewModel)
    func showImagePicker(model: MediaPickerViewModel)
    
    func saveFile(fileURL: URL)
    
    func showCodeLanguageView(languages: [CodeLanguage], completion: @escaping (CodeLanguage) -> Void)
    
    func showStyleMenu(information: BlockInformation)
    func showSettings(viewModel: ObjectSettingsViewModel)
    func showCoverPicker(viewModel: ObjectCoverPickerViewModel)
    func showIconPicker(viewModel: ObjectIconPickerViewModel)
    
    func showMoveTo(onSelect: @escaping (BlockId) -> ())
    func showLinkTo(onSelect: @escaping (BlockId) -> ())
    func showSearch(onSelect: @escaping (BlockId) -> ())
    func showTypesSearch(onSelect: @escaping (BlockId) -> ())
    
    func goBack()
}

protocol AttachmentRouterProtocol {
    func openImage(_ imageContext: BlockImageViewModel.ImageOpeningContext)
}

final class EditorRouter: EditorRouterProtocol {
    private weak var rootController: EditorBrowserController?
    private weak var viewController: EditorPageController?
    private let fileRouter: FileRouter
    private let document: BaseDocumentProtocol
    private let settingAssembly = ObjectSettingAssembly()
    private let pageAssembly: EditorPageAssembly

    init(
        rootController: EditorBrowserController,
        viewController: EditorPageController,
        document: BaseDocumentProtocol,
        assembly: EditorPageAssembly
    ) {
        self.rootController = rootController
        self.viewController = viewController
        self.document = document
        self.pageAssembly = assembly
        self.fileRouter = FileRouter(fileLoader: FileLoader(), viewController: viewController)
    }

    /// Show page
    func showPage(with id: BlockId) {
        if let details = document.detailsStorage.get(id: id) {
            let typeUrl = details.type
            guard ObjectTypeProvider.isSupported(typeUrl: typeUrl) else {
                let typeName = ObjectTypeProvider.objectType(url: typeUrl)?.name ?? "Unknown".localized
                
                AlertHelper.showToast(
                    title: "Not supported type \"\(typeName)\"",
                    message: "You can open it via desktop"
                )
                return
            }
        }
        
        let newEditorViewController = pageAssembly.buildEditorPage(pageId: id)
        
        viewController?.navigationController?.pushViewController(
            newEditorViewController,
            animated: true
        )
    }
    
    func openUrl(_ url: URL) {
        let url = url.urlByAddingHttpIfSchemeIsEmpty()
        if url.containsHttpProtocol {
            let safariController = SFSafariViewController(url: url)
            viewController?.present(safariController, animated: true)
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
    
    func saveFile(fileURL: URL) {
        fileRouter.saveFile(fileURL: fileURL)
    }
    
    func showCodeLanguageView(languages: [CodeLanguage], completion: @escaping (CodeLanguage) -> Void) {
        let searchListViewController = SearchListViewController(items: languages, completion: completion)
        searchListViewController.modalPresentationStyle = .pageSheet
        viewController?.present(searchListViewController, animated: true)
    }
    
    func showStyleMenu(information: BlockInformation) {
        guard let controller = viewController,
              let container = document.blocksContainer.model(id: document.objectId)?.container,
              let rootController = rootController,
              let blockModel = container.model(id: information.id) else { return }

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
            actionHandler: controller.viewModel.blockActionHandler,
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
        guard let viewController = rootController else {
            return
        }
        
        let controller = UIHostingController(
            rootView: ObjectSettingsContainerView(
                viewModel: viewModel
            )
        )
        controller.modalPresentationStyle = .overCurrentContext
        
        controller.view.backgroundColor = .clear
        controller.view.isOpaque = false
        
        controller.rootView.onHide = { [weak controller] in
            controller?.dismiss(animated: false)
        }
        
        viewController.present(controller, animated: false)
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
        let moveToView = SearchView(kind: .objects, title: "Move to".localized) { id in
            onSelect(id)
        }
        
        presentSwuftUIView(view: moveToView)
    }
    
    func showLinkTo(onSelect: @escaping (BlockId) -> ()) {
        let linkToView = SearchView(kind: .objects, title: "Link to".localized) { id in
            onSelect(id)
        }
        
        presentSwuftUIView(view: linkToView)
    }
    
    func showSearch(onSelect: @escaping (BlockId) -> ()) {
        let searchView = SearchView(kind: .objects, title: nil) { id in
            onSelect(id)
        }
        
        presentSwuftUIView(view: searchView)
    }
    
    func showTypesSearch(onSelect: @escaping (BlockId) -> ()) {
        let searchView = SearchView(
            kind: .objectTypes,
            title: "Change type".localized
        ) { id in
            onSelect(id)
        }
        presentSwuftUIView(view: searchView)
    }
    
    func goBack() {
        rootController?.pop()
    }
    
    private func presentSwuftUIView<Content: View>(view: Content) {
        guard let viewController = viewController else { return }
        
        let controller = UIHostingController(rootView: view)
        viewController.present(controller, animated: true)
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
