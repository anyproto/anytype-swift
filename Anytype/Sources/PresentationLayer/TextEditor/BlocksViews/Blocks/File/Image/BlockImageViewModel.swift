import UIKit
import Services
import Combine
import Kingfisher
import AnytypeCore

struct BlockImageViewModel: BlockViewModelProtocol {
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
                "Wrong content type of \(fileData), image expected"
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
                fileData: fileData,
                imageViewTapHandler: didTapOpenImage
            )
            .cellBlockConfiguration(
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
    
    private func didTapOpenImage(_ sender: UIImageView) {
        onImageOpen?(
            .init(
                file: ImagePreviewMedia(file: fileData, blockId: info.id, previewImage: sender.image),
                sourceView: sender, previewImage: sender.image, onDidEditFile: { url in
                    handler.uploadMediaFile(
                        uploadingSource: .path(url.relativePath),
                        type: .images,
                        blockId: info.id
                    )
                }
            )
        )
    }
}

