import UIKit
import BlocksModels
import Combine

struct BlockFileViewModel: BlockViewModelProtocol {    
    var hashable: AnyHashable { [ info ] as [AnyHashable] }
    
    let info: BlockInformation
    let fileData: BlockFile
    
    let showFilePicker: (BlockId) -> ()
    let downloadFile: (FileId) -> ()
    
    func didSelectRowInTableView(editorEditingState: EditorEditingState) {
        switch fileData.state {
        case .done:
            downloadFile(fileData.metadata.hash)
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
            return emptyViewConfiguration(state: .default)
        case .uploading:
            return emptyViewConfiguration(state: .uploading)
        case .error:
            return emptyViewConfiguration(state: .error)
        case .done:
            return BlockFileConfiguration(data: fileData.mediaData).asCellBlockConfiguration
        }
    }
    
    private func emptyViewConfiguration(state: BlocksFileEmptyViewState) -> UIContentConfiguration {
        BlocksFileEmptyViewConfiguration(
            image: UIImage.blockFile.empty.file,
            text: "Upload a file",
            state: state
        ).asCellBlockConfiguration
    }
}
