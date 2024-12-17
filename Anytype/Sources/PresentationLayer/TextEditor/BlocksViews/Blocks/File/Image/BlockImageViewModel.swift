import UIKit
import Services
import Combine
import AnytypeCore

struct BlockImageViewModel: BlockViewModelProtocol {
    typealias Action<T> = (_ arg: T) -> Void
    
    @Injected(\.documentService)
    private var documentService: any OpenedDocumentsProviderProtocol
    
    var hashable: AnyHashable { info.id }
    
    var info: BlockInformation { blockInformationProvider.info }
    let documentId: String
    let spaceId: String
    let blockInformationProvider: BlockModelInfomationProvider
    let handler: any BlockActionHandlerProtocol
    
    let showIconPicker: Action<String>
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
        documentId: String,
        spaceId: String,
        blockInformationProvider: BlockModelInfomationProvider,
        handler: some BlockActionHandlerProtocol,
        showIconPicker: @escaping (String) -> (),
        onImageOpen: Action<FilePreviewContext>?
    ) {
        self.documentId = documentId
        self.spaceId = spaceId
        self.blockInformationProvider = blockInformationProvider
        self.handler = handler
        self.showIconPicker = showIconPicker
        self.onImageOpen = onImageOpen
    }
    
    func makeContentConfiguration(maxWidth: CGFloat) -> any UIContentConfiguration {
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
                styleConfiguration: CellStyleConfiguration(backgroundColor: info.backgroundColor?.backgroundColor.color)
            )
        }
    }
        
    private func emptyViewConfiguration(text: String, state: BlocksFileEmptyViewState) -> some UIContentConfiguration {
        BlocksFileEmptyViewConfiguration(
            imageAsset: .X32.image,
            text: text,
            state: state
        ).cellBlockConfiguration(
            dragConfiguration: .init(id: info.id),
            styleConfiguration: CellStyleConfiguration(backgroundColor: info.backgroundColor?.backgroundColor.color)
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
        let document = documentService.document(objectId: documentId, spaceId: spaceId)
        guard let fileDetails = document.targetFileDetails(targetObjectId: fileData.metadata.targetObjectId) else {
            anytypeAssertionFailure("File details not found")
            return
        }
        onImageOpen?(
            FilePreviewContext(
                previewItem: ImagePreviewMedia(previewImage: sender.image, fileDetails: fileDetails),
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

