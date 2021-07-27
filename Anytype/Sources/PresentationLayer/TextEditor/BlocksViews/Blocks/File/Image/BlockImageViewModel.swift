import UIKit
import BlocksModels
import Combine
import Kingfisher
import AnytypeCore

struct BlockImageViewModel: BlockViewModelProtocol {
    var hashable: AnyHashable {
        [
            indentationLevel,
            information,
        ] as [AnyHashable]
    }
    
    let information: BlockInformation
    let fileData: BlockFile
    
    let contextualMenuHandler: DefaultContextualMenuHandler
    let indentationLevel: Int
    let showIconPicker: (BlockId) -> ()
    
    init?(
        information: BlockInformation,
        fileData: BlockFile,
        indentationLevel: Int,
        contextualMenuHandler: DefaultContextualMenuHandler,
        showIconPicker: @escaping (BlockId) -> ()
    ) {
        guard fileData.contentType == .image else {
            anytypeAssertionFailure("Wrong content type of \(fileData), image expected")
            return nil
        }
        
        self.information = information
        self.fileData = fileData
        self.contextualMenuHandler = contextualMenuHandler
        self.indentationLevel = indentationLevel
        self.showIconPicker = showIconPicker
    }
    
    func makeContextualMenu() -> [ContextualMenu] {
        BlockFileContextualMenuBuilder.contextualMenu(fileData: fileData)
    }
    
    func handle(action: ContextualMenu) {
        switch action {
        case .replace:
            showIconPicker(blockId)
        case .download:
            downloadImage()
        default:
            contextualMenuHandler.handle(action: action, info: information)
        }
    }
    
    func makeContentConfiguration() -> UIContentConfiguration {
        switch fileData.state {
        case .empty:
            return emptyViewConfiguration(state: .default)
        case .error:
            return emptyViewConfiguration(state: .error)
        case .uploading:
            return emptyViewConfiguration(state: .uploading)
        case .done:
            return BlockImageConfiguration(fileData)
        }
    }
        
    private func emptyViewConfiguration(state: BlocksFileEmptyViewState) -> UIContentConfiguration {
        BlocksFileEmptyViewConfiguration(
            image: UIImage.blockFile.empty.image,
            text: "Upload a picture".localized,
            state: state
        )
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
        guard
            let url = UrlResolver.resolvedUrl(.image(id: fileData.metadata.hash, width: .default))
        else {
            return
        }
        
        let saveAction = UIAlertAction(title: "Yes", style: .default) { _ in
            KingfisherManager.shared.retrieveImage(with: url) { result in
                guard case let .success(success) = result else { return }
                
                UIImageWriteToSavedPhotosAlbum(success.image, nil, nil, nil)
            }
        }

        let alert = UIAlertController(title: "Save image to the gallery?", message: "", preferredStyle: .alert)
        alert.addAction(saveAction)
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        windowHolder?.rootNavigationController.present(alert, animated: true, completion: nil)
    }
}
