import Services
import UIKit
import AnytypeCore

final class OpenFileBlockViewModel: BlockViewModelProtocol {
    var hashable: AnyHashable { info.id }
    
    let info: BlockInformation
    
    @Injected(\.openedDocumentProvider)
    private var documentService: any OpenedDocumentsProviderProtocol
    
    private var document: (any BaseDocumentProtocol)?
    private let onFileOpen: (ScreenData) -> ()
    
    init(
        info: BlockInformation,
        documentId: String,
        spaceId: String,
        onFileOpen: @escaping (ScreenData) -> ()
    ) {
        self.info = info
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
        onFileOpen(.preview(MediaFileScreenData(items: [fileDetails.previewRemoteItem])))
    }
}
