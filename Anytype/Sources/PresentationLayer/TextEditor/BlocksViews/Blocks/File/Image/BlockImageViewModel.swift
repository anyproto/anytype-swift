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
    
    var hashable: AnyHashable { [ info ] as [AnyHashable] }
    
    let info: BlockInformation
    let fileData: BlockFile
    
    let showIconPicker: Action<BlockId>
    let onImageOpen: Action<ImageOpeningContext>?
    
    init?(
        info: BlockInformation,
        fileData: BlockFile,
        showIconPicker: @escaping (BlockId) -> (),
        onImageOpen: Action<ImageOpeningContext>?
    ) {
        guard fileData.contentType == .image else {
            anytypeAssertionFailure(
                "Wrong content type of \(fileData), image expected",
                domain: .blockImage
            )
            return nil
        }
        
        self.info = info
        self.fileData = fileData
        self.showIconPicker = showIconPicker
        self.onImageOpen = onImageOpen
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
                alignmetn: info.alignment,
                maxWidth: maxWidth,
                imageViewTapHandler: { [weak self] imageView in
                    self?.didTapOpenImage(imageView)
                }
            ).asCellBlockConfiguration
        }
    }
        
    private func emptyViewConfiguration(state: BlocksFileEmptyViewState) -> UIContentConfiguration {
        BlocksFileEmptyViewConfiguration(
            image: UIImage.blockFile.empty.image,
            text: "Upload a picture".localized,
            state: state
        ).asCellBlockConfiguration
    }

    func didSelectRowInTableView(editorEditingState: EditorEditingState) {
        switch fileData.state {
        case .empty, .error:
            guard case .editing = editorEditingState else { return }
            showIconPicker(blockId)
        case .uploading, .done:
            return
        }
    }

    private func downloadImage() {
        guard
            let url = ImageMetadata(id: fileData.metadata.hash, width: .original).downloadingUrl
        else {
            return
        }

        AnytypeImageDownloader.retrieveImage(with: url, options: nil) { image in
            guard let image = image else { return }

            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
    }
    
    private func didTapOpenImage(_ sender: UIImageView) {
        let imageId = ImageMetadata(id: fileData.metadata.hash, width: .original)

        onImageOpen?(.init(image: .middleware(imageId), imageView: sender))
    }
}
