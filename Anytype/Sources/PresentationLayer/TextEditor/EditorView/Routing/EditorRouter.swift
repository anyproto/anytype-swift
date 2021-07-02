import UIKit
import BlocksModels
import SafariServices
import Combine
import SwiftUI
import FloatingPanel

typealias FilePickerModel = CommonViews.Pickers.File.Picker.ViewModel

protocol EditorRouterProtocol: AnyObject {
    
    func showPage(with id: BlockId)
    func openUrl(_ url: URL)
    func showBookmarkBar(completion: @escaping (URL) -> ())
    
    func showFilePicker(model: FilePickerModel)
    func showImagePicker(model: MediaPickerViewModel)
    
    func saveFile(fileURL: URL)
    
    func showCodeLanguageView(languages: [String], completion: @escaping (String) -> Void)
    
    func showStyleMenu(information: BlockInformation)
}

final class EditorRouter: EditorRouterProtocol {
    private weak var viewController: DocumentEditorViewController?
    private let fileRouter: FileRouter
    private lazy var dimmingTransitionDelegate = DimmingTransitionDelegate()

    init(viewController: DocumentEditorViewController) {
        self.viewController = viewController
        self.fileRouter = FileRouter(fileLoader: FileLoader(), viewController: viewController)
    }

    /// Show page
    func showPage(with id: BlockId) {
        let newEditorViewController = EditorAssembly.build(blockId: id)
        
        viewController?.navigationController?.pushViewController(
            newEditorViewController,
            animated: true
        )
    }
    
    func openUrl(_ url: URL) {
        guard url.containsHttpProtocol else {
            return
        }
        
        let safariController = SFSafariViewController(url: url)
        viewController?.present(safariController, animated: true, completion: nil)
    }
    
    func showBookmarkBar(completion: @escaping (URL) -> ()) {
        
        let controller = UIHostingController(rootView: URLInputView(didCreateURL: completion))
        controller.rootView.dismissAction = { [weak controller] in
            controller?.dismiss(animated: true)
        }
        controller.modalPresentationStyle = .overCurrentContext
        controller.view.backgroundColor = .clear
        controller.view.isOpaque = false
        controller.transitioningDelegate = dimmingTransitionDelegate
        controller.modalPresentationStyle = .custom
        viewController?.present(controller, animated: true)
    }
    
    func showFilePicker(model: FilePickerModel) {
        let vc = CommonViews.Pickers.File.Picker(model)
        viewController?.present(vc, animated: true, completion: nil)
    }
    
    func showImagePicker(model: MediaPickerViewModel) {
        let vc = MediaPicker(viewModel: model)
        viewController?.present(vc, animated: true, completion: nil)
    }
    
    func saveFile(fileURL: URL) {
        fileRouter.saveFile(fileURL: fileURL)
    }
    
    func showCodeLanguageView(languages: [String], completion: @escaping (String) -> Void) {
        let searchListViewController = SearchListViewController(items: languages, completion: completion)
        searchListViewController.modalPresentationStyle = .pageSheet
        viewController?.present(searchListViewController, animated: true)
    }
    
    func showStyleMenu(information: BlockInformation) {
        guard let controller = viewController, let parentController = controller.parent else { return }
        controller.view.endEditing(true)

        BottomSheetsFactory.createStyleBottomSheet(
            parentViewController: parentController,
            delegate: controller,
            information: information
        ) { [weak controller] action in
            controller?.viewModel.blockActionHandler.handleActionForFirstResponder(action)
        }
        
        controller.selectBlock(blockId: information.id)
    }
}
