import UIKit
import Services
import Combine
import Kingfisher
import AnytypeCore

struct BlockImageViewModel: BlockViewModelProtocol {
    typealias Action<T> = (_ arg: T) -> Void
    
    var hashable: AnyHashable { info.id }
    
    var info: BlockInformation { blockInformationProvider.info }
    let blockInformationProvider: BlockModelInfomationProvider
    let handler: BlockActionHandlerProtocol
    
    let showIconPicker: Action<BlockId>
    let onImageOpen: Action<FilePreviewContext>?
    
    var fileData: BlockFile? {
        guard case let .file(fileData) = info.content else { return nil }
        guard fileData.contentType == .image else {
            anytypeAssertionFailure(
                "Wrong content type, image expected", info: ["contentType": "\(fileData.contentType)"]
            )
            return nil
        }
        
        return fileData
    }
    
    init?(
        blockInformationProvider: BlockModelInfomationProvider,
        handler: BlockActionHandlerProtocol,
        showIconPicker: @escaping (BlockId) -> (),
        onImageOpen: Action<FilePreviewContext>?
    ) {
        self.blockInformationProvider = blockInformationProvider
        self.handler = handler
        self.showIconPicker = showIconPicker
        self.onImageOpen = onImageOpen
    }
    
    func makeContentConfiguration(maxWidth: CGFloat) -> UIContentConfiguration {
        guard let fileData else {
            anytypeAssertionFailure("UnsupportedBlockViewModel has wrong content type")
            return UnsupportedBlockViewModel(info: info).makeContentConfiguration(maxWidth: maxWidth)
        }
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
            ).cellBlockConfiguration(
                dragConfiguration: .init(id: info.id),
                styleConfiguration: .init(backgroundColor: info.backgroundColor?.backgroundColor.color)
            )
        }
    }
        
    private func emptyViewConfiguration(text: String, state: BlocksFileEmptyViewState) -> UIContentConfiguration {
        BlocksFileEmptyViewConfiguration(
            imageAsset: .X32.image,
            text: text,
            state: state
        ).cellBlockConfiguration(
            dragConfiguration: .init(id: info.id),
            styleConfiguration: .init(backgroundColor: info.backgroundColor?.backgroundColor.color)
        )
    }

    func didSelectRowInTableView(editorEditingState: EditorEditingState) {
        guard let fileData else { return }
        switch fileData.state {
        case .empty, .error:
            guard case .editing = editorEditingState else { return }
            showIconPicker(blockId)
        case .uploading, .done:
            return
        }
    }
    
    private func didTapOpenImage(_ sender: UIImageView) {
        guard let fileData else { return }
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

