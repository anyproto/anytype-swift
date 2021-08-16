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
    func showLinkMarkup(url: URL?, completion: @escaping (URL?) -> Void)
    
    func showFilePicker(model: FilePickerModel)
    func showImagePicker(model: MediaPickerViewModel)
    
    func saveFile(fileURL: URL)
    
    func showCodeLanguageView(languages: [CodeLanguage], completion: @escaping (CodeLanguage) -> Void)
    
    func showStyleMenu(information: BlockInformation)
}

final class EditorRouter: EditorRouterProtocol {
    private weak var viewController: DocumentEditorViewController?
    private let fileRouter: FileRouter
    private let document: BaseDocumentProtocol

    init(
        viewController: DocumentEditorViewController,
        document: BaseDocumentProtocol
    ) {
        self.viewController = viewController
        self.document = document
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
        showURLInputViewController { url in
            guard let url = url else { return }
            completion(url)
        }
    }
    
    func showLinkMarkup(url: URL?, completion: @escaping (URL?) -> Void) {
        showURLInputViewController(url: url, completion: completion)
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
    
    func showCodeLanguageView(languages: [CodeLanguage], completion: @escaping (CodeLanguage) -> Void) {
        let searchListViewController = SearchListViewController(items: languages, completion: completion)
        searchListViewController.modalPresentationStyle = .pageSheet
        viewController?.present(searchListViewController, animated: true)
    }
    
    func showStyleMenu(information: BlockInformation) {
        guard let controller = viewController,
              let parentController = controller.parent else { return }
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
            parentViewController: parentController,
            delegate: controller,
            information: information,
            actionHandler: controller.viewModel.blockActionHandler,
            didShow: didShow,
            showMarkupMenu: { [weak controller, weak self] in
                guard let controller = controller,
                      let parent = controller.parent,
                      let container = self?.document.rootActiveModel?.container,
                      let actualInformation = container.model(id: information.id)?.information else {
                    return
                }
                BottomSheetsFactory.showMarkupBottomSheet(
                    parentViewController: parent,
                    blockInformation: actualInformation,
                    viewModel: controller.viewModel.wholeBlockMarkupViewModel
                )
            }
        )
        controller.selectBlock(blockId: information.id)
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
