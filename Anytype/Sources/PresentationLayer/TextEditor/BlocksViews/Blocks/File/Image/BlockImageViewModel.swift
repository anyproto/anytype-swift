import UIKit
import BlocksModels
import Combine
import Kingfisher
import AnytypeCore

final class BlockImageViewModel: BlockViewModelProtocol {
    typealias Action<T> = (_ arg: T) -> Void
    
    var hashable: AnyHashable { [ info ] as [AnyHashable] }
    
    let info: BlockInformation
    let fileData: BlockFile
    let handler: BlockActionHandlerProtocol
    
    let showIconPicker: Action<BlockId>
    let onImageOpen: Action<FilePreviewContext>?
    
    init?(
        info: BlockInformation,
        fileData: BlockFile,
        handler: BlockActionHandlerProtocol,
        showIconPicker: @escaping (BlockId) -> (),
        onImageOpen: Action<FilePreviewContext>?
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
        self.handler = handler
        self.showIconPicker = showIconPicker
        self.onImageOpen = onImageOpen
    }
    
    func makeContentConfiguration(maxWidth: CGFloat) -> UIContentConfiguration {
        switch fileData.state {
        case .empty:
            return emptyViewConfiguration(text: Loc.Content.Picture.upload, state: .default)
        case .error:
            return emptyViewConfiguration(text: Loc.Content.Common.error, state: .error)
        case .uploading:
            return emptyViewConfiguration(text: Loc.Content.Common.uploading, state: .uploading)
        case .done:
            return BlockImageConfiguration(
                blockId: info.id,
                maxWidth: maxWidth,
                alignment: info.horizontalAlignment,
                fileData: fileData
            ) { [weak self] imageView in
                self?.didTapOpenImage(imageView)
            }.cellBlockConfiguration(
                indentationSettings: .init(with: info.configurationData),
                dragConfiguration: .init(id: info.id)
            )
        }
    }
        
    private func emptyViewConfiguration(text: String, state: BlocksFileEmptyViewState) -> UIContentConfiguration {
        BlocksFileEmptyViewConfiguration(
            imageAsset: .TextEditor.BlockFile.Empty.image,
            text: text,
            state: state
        ).cellBlockConfiguration(
            indentationSettings: .init(with: info.configurationData),
            dragConfiguration: .init(id: info.id)
        )
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
            let url = ImageMetadata(id: fileData.metadata.hash, width: .original).contentUrl
        else {
            return
        }

        AnytypeImageDownloader.retrieveImage(with: url, options: nil) { image in
            guard let image = image else { return }

            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
    }
    
    private func didTapOpenImage(_ sender: UIImageView) {
        onImageOpen?(
            .init(
                file: ImagePreviewMedia(file: fileData, blockId: info.id, previewImage: sender.image),
                sourceView: sender, previewImage: sender.image, onDidEditFile: {  [weak self] url in
                    guard let info = self?.info else {
                        return
                    }

                    self?.handler.uploadMediaFile(
                        uploadingSource: .url(url),
                        type: .images,
                        blockId: info.id
                    )
                }
            )
        )
    }
}

