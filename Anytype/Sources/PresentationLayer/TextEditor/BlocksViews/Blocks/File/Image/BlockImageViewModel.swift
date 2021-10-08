import UIKit
import BlocksModels
import Combine
import Kingfisher
import AnytypeCore

final class BlockImageViewModel: BlockViewModelProtocol {
    typealias Action<T> = (_ arg: T) -> Void

    var upperBlock: BlockModelProtocol?
    
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
    let showIconPicker: Action<BlockId>

    var onImageSelection: Action<ImageSource>?
    
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
            openImage()
        default:
            contextualMenuHandler.handle(action: action, info: information)
        }
    }
    
    func makeContentConfiguration(maxWidth: CGFloat) -> UIContentConfiguration {
        switch fileData.state {
        case .empty:
            return emptyViewConfiguration(state: .default)
        case .error:
            return emptyViewConfiguration(state: .error)
        case .uploading:
            return emptyViewConfiguration(state: .uploading)
        case .done:
            return BlockImageConfiguration(
                fileData: fileData,
                alignmetn: information.alignment,
                maxWidth: maxWidth
            )
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
            openImage()
        case .empty, .error:
            showIconPicker(blockId)
        case .uploading:
            return
        }
    }
    
    private func openImage() {
        let imageId = ImageID(id: fileData.metadata.hash, width: .original)

        onImageSelection?(.middleware(imageId))
    }
}
