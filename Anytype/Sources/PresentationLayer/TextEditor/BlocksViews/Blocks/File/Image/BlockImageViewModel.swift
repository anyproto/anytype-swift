import UIKit
import BlocksModels
import Combine
import Kingfisher
import AnytypeCore

final class BlockImageViewModel: BlockViewModelProtocol {
    typealias Action<T> = (_ arg: T) -> Void

    struct ImageOpeningContext {
        let image: ImageSource
        let imageView: UIImageView
    }

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

    var onImageOpen: Action<ImageOpeningContext>?
    
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
                maxWidth: maxWidth,
                imageViewTapHandler: { [weak self] imageView in
                    self?.didTapOpenImage(imageView)
                }
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
        case .empty, .error:
            showIconPicker(blockId)
        case .uploading, .done:
            return
        }
    }

    private func downloadImage() {
        guard
            let url = ImageID(id: fileData.metadata.hash, width: .original).resolvedUrl
        else {
            return
        }

        KingfisherManager.shared.retrieveImage(with: url) { result in
            guard case let .success(success) = result else { return }

            UIImageWriteToSavedPhotosAlbum(success.image, nil, nil, nil)
        }
    }
    
    private func didTapOpenImage(_ sender: UIImageView) {
        let imageId = ImageID(id: fileData.metadata.hash, width: .original)

        onImageOpen?(.init(image: .middleware(imageId), imageView: sender))
    }
}
