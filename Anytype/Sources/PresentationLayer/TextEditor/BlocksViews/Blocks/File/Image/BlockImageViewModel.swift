import UIKit
import BlocksModels
import Combine

struct BlockImageViewModel: BlockViewModelProtocol {
    var diffable: AnyHashable {
        [
            blockId,
            fileData,
            indentationLevel
        ] as [AnyHashable]
    }
    
    let isStruct = true
    
    let information: BlockInformation
    let fileData: BlockFile
    
    let contextualMenuHandler: DefaultContextualMenuHandler
    
    let indentationLevel: Int
    let showIconPicker: (BlockId) -> ()
    
    let imageLoader = ImageLoader()
    
    init?(
        information: BlockInformation,
        fileData: BlockFile,
        indentationLevel: Int,
        contextualMenuHandler: DefaultContextualMenuHandler,
        showIconPicker: @escaping (BlockId) -> ()
    ) {
        guard fileData.contentType == .image else {
            assertionFailure("Wrong content type of \(fileData), image expected")
            return nil
        }
        
        self.information = information
        self.fileData = fileData
        self.contextualMenuHandler = contextualMenuHandler
        self.indentationLevel = indentationLevel
        self.showIconPicker = showIconPicker
    }
    
    func makeContentConfiguration() -> UIContentConfiguration {
        BlockImageConfiguration(fileData)
    }
    
    func makeContextualMenu() -> ContextualMenu {
        BlockFileContextualMenuBuilder.contextualMenu(fileData: fileData)
    }
    
    func handle(action: ContextualMenuAction) {
        switch action {
        case .replace:
            showIconPicker(blockId)
        case .download:
            downloadImage()
        default:
            contextualMenuHandler.handle(action: action, info: information)
        }
    }
    
    func didSelectRowInTableView() {
        switch fileData.state {
        case .done:
            downloadImage()
        case .empty, .error:
            showIconPicker(blockId)
        case .uploading:
            return
        }

    }
    
    private func downloadImage() {
        guard let image = ImageProperty(imageId: fileData.metadata.hash).property else {
            return
        }

        let alert = UIAlertController(title: "Save image to the gallery?", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default) { _ in UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil) })
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        windowHolder?.rootNavigationController.present(alert, animated: true, completion: nil)
    }
    
    func updateView() { }
}
