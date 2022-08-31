import UIKit
import BlocksModels
import Combine

struct BlockFileViewModel: BlockViewModelProtocol {    
    var hashable: AnyHashable { [ info ] as [AnyHashable] }
    
    let info: BlockInformation
    let fileData: BlockFile
    
    let showFilePicker: (BlockId) -> ()
    let downloadFile: (FileMetadata) -> ()
    
    func didSelectRowInTableView(editorEditingState: EditorEditingState) {
        switch fileData.state {
        case .done:
            downloadFile(fileData.metadata)
        case .empty, .error:
            if case .locked = editorEditingState { return }
            showFilePicker(blockId)
        case .uploading:
            return
        }
    }
    
    func makeContentConfiguration(maxWidth _ : CGFloat) -> UIContentConfiguration {
        switch fileData.state {
        case .empty:
            return emptyViewConfiguration(text: Loc.Content.File.upload, state: .default)
        case .uploading:
            return emptyViewConfiguration(text: Loc.Content.Common.uploading, state: .uploading)
        case .error:
            return emptyViewConfiguration(text: Loc.Content.Common.error, state: .error)
        case .done:
            return BlockFileConfiguration(data: fileData.mediaData).cellBlockConfiguration(
                indentationSettings: .init(with: info.configurationData),
                dragConfiguration: .init(id: info.id)
            )
        }
    }
    
    private func emptyViewConfiguration(text: String, state: BlocksFileEmptyViewState) -> UIContentConfiguration {
        BlocksFileEmptyViewConfiguration(
            imageAsset: .TextEditor.BlockFile.Empty.file,
            text: text,
            state: state
        ).cellBlockConfiguration(
            indentationSettings: .init(with: info.configurationData),
            dragConfiguration: .init(id: info.id)
        )
    }
}
