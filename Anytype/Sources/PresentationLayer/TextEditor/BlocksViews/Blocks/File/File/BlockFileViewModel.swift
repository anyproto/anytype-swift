import UIKit
import Services
import Combine
import AnytypeCore

final class BlockFileViewModel: BlockViewModelProtocol {
    let className = "BlockFileViewModel"
    nonisolated var info: BlockInformation { informationProvider.info }
    
    let informationProvider: BlockModelInfomationProvider
    let documentId: String
    let spaceId: String
    let showFilePicker: (String) -> ()
    let onFileOpen: (ScreenData) -> ()
    
    @Injected(\.openedDocumentProvider)
    private var documentService: any OpenedDocumentsProviderProtocol
    
    private var document: (any BaseDocumentProtocol)?
    
    init(
        informationProvider: BlockModelInfomationProvider,
        documentId: String,
        spaceId: String,
        showFilePicker: @escaping (String) -> (),
        onFileOpen: @escaping (ScreenData) -> ()
    ) {
        self.informationProvider = informationProvider
        self.documentId = documentId
        self.spaceId = spaceId
        self.showFilePicker = showFilePicker
        self.onFileOpen = onFileOpen
        self.document = documentService.document(objectId: documentId, spaceId: spaceId)
    }

    func didSelectRowInTableView(editorEditingState: EditorEditingState) {
        guard case let .file(fileData) = info.content else { return }
        switch fileData.state {
        case .done:
            guard let fileDetails = document?.targetFileDetails(targetObjectId: fileData.metadata.targetObjectId) else {
                anytypeAssertionFailure("File details not found")
                return
            }
            onFileOpen(.preview(MediaFileScreenData(items: [fileDetails.previewRemoteItem])))
        case .empty, .error:
            if case .readonly = editorEditingState { return }
            showFilePicker(blockId)
        case .uploading:
            return
        }
    }
    
    func makeContentConfiguration(maxWidth width: CGFloat) -> any UIContentConfiguration {
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
            return BlockFileConfiguration(data: fileData.mediaData(documentId: documentId, spaceId: spaceId)).cellBlockConfiguration(
                dragConfiguration: .init(id: info.id),
                styleConfiguration: CellStyleConfiguration(backgroundColor: info.backgroundColor?.backgroundColor.color)
            )
        }
    }
    
    private func emptyViewConfiguration(text: String, state: BlocksFileEmptyViewState) -> any UIContentConfiguration {
        BlocksFileEmptyViewConfiguration(
            imageAsset: .X32.file,
            text: text,
            state: state
        ).cellBlockConfiguration(
            dragConfiguration: .init(id: info.id),
            styleConfiguration: CellStyleConfiguration(backgroundColor: info.backgroundColor?.backgroundColor.color)
        )
    }
}
