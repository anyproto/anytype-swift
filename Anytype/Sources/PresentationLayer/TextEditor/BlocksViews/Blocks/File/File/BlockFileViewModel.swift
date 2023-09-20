import UIKit
import Services
import Combine
import AnytypeCore

final class BlockFileViewModel: BlockViewModelProtocol {
    var hashable: AnyHashable { info.id }
    var info: BlockInformation { informationProvider.info }
    
    let informationProvider: BlockModelInfomationProvider
    let handler: BlockActionHandlerProtocol
    let showFilePicker: (BlockId) -> ()
    let onFileOpen: (FilePreviewContext) -> ()
    
    init(
        informationProvider: BlockModelInfomationProvider,
        handler: BlockActionHandlerProtocol,
        showFilePicker: @escaping (BlockId) -> (),
        onFileOpen: @escaping (FilePreviewContext) -> ()
    ) {
        self.informationProvider = informationProvider
        self.handler = handler
        self.showFilePicker = showFilePicker
        self.onFileOpen = onFileOpen
    }

    func didSelectRowInTableView(editorEditingState: EditorEditingState) {
        guard case let .file(fileData) = info.content else { return }
        switch fileData.state {
        case .done:
            onFileOpen(
                .init(
                    file: FilePreviewMedia(file: fileData, blockId: info.id),
                    sourceView: nil,
                    previewImage: nil,
                    onDidEditFile: { [weak self] url in
                        guard let self else { return }
                        handler.uploadFileAt(localPath: url.relativePath, blockId: info.id)
                    }
                )
            )
        case .empty, .error:
            if case .readonly = editorEditingState { return }
            showFilePicker(blockId)
        case .uploading:
            return
        }
    }
    
    func makeContentConfiguration(maxWidth width: CGFloat) -> UIContentConfiguration {
        guard case let .file(fileData) = info.content else {
            anytypeAssertionFailure("BlockFileViewModel has wrong info.content")
            return UnsupportedBlockViewModel(info: info).makeContentConfiguration(maxWidth: width)
        }
        
        switch fileData.state {
        case .empty:
            return emptyViewConfiguration(text: Loc.Content.File.upload, state: .default)
        case .uploading:
            return emptyViewConfiguration(text: Loc.Content.Common.uploading, state: .uploading)
        case .error:
            return emptyViewConfiguration(text: Loc.Content.Common.error, state: .error)
        case .done:
            return BlockFileConfiguration(data: fileData.mediaData).cellBlockConfiguration(
                dragConfiguration: .init(id: info.id),
                styleConfiguration: .init(backgroundColor: info.backgroundColor?.backgroundColor.color)
            )
        }
    }
    
    private func emptyViewConfiguration(text: String, state: BlocksFileEmptyViewState) -> UIContentConfiguration {
        BlocksFileEmptyViewConfiguration(
            imageAsset: .X32.file,
            text: text,
            state: state
        ).cellBlockConfiguration(
            dragConfiguration: .init(id: info.id),
            styleConfiguration: .init(backgroundColor: info.backgroundColor?.backgroundColor.color)
        )
    }
}
