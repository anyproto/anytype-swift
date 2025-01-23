import Services
import UIKit
import AnytypeCore

final class OpenFileBlockViewModel: BlockViewModelProtocol {
    var hashable: AnyHashable { info.id }
    
    let info: BlockInformation
    
    @Injected(\.documentService)
    private var documentService: any OpenedDocumentsProviderProtocol
    private let handler: any BlockActionHandlerProtocol
    
    private var document: (any BaseDocumentProtocol)?
    private let onFileOpen: (FilePreviewContext) -> ()
    
    init(
        info: BlockInformation,
        handler: some BlockActionHandlerProtocol,
        documentId: String,
        spaceId: String,
        onFileOpen: @escaping (FilePreviewContext) -> ()
    ) {
        self.info = info
        self.handler = handler
        self.onFileOpen = onFileOpen
        
        self.document = documentService.document(objectId: documentId, spaceId: spaceId)
    }
    
    func makeContentConfiguration(maxWidth _ : CGFloat) -> any UIContentConfiguration {
        OpenFileBlockContentConfiguration()
            .cellBlockConfiguration(
                dragConfiguration: .init(id: info.id),
                styleConfiguration: CellStyleConfiguration(backgroundColor: info.backgroundColor?.backgroundColor.color)
            )
    }
    
    func didSelectRowInTableView(editorEditingState: EditorEditingState) {
        guard case let .file(fileData) = info.content else { return }
        guard let fileDetails = document?.targetFileDetails(targetObjectId: fileData.metadata.targetObjectId) else {
            anytypeAssertionFailure("File details not found")
            return
        }
        onFileOpen(
            FilePreviewContext(
                previewItem: PreviewRemoteItem(fileDetails: fileDetails, type: .file),
                sourceView: nil,
                previewImage: nil,
                onDidEditFile: { [weak self] url in
                    guard let self else { return }
                    handler.uploadFileAt(localPath: url.relativePath, blockId: info.id)
                }
            )
        )
        
    }
}
