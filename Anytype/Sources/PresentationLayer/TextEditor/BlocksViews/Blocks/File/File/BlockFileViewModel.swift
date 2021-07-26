import UIKit
import BlocksModels
import Combine

struct BlockFileViewModel: BlockViewModelProtocol {
    var hashable: AnyHashable {
        [
            indentationLevel,
            information
        ] as [AnyHashable]
    }
    
    let indentationLevel: Int
    let information: BlockInformation
    let fileData: BlockFile
    
    let contextualMenuHandler: DefaultContextualMenuHandler
    let showFilePicker: (BlockId) -> ()
    let downloadFile: (FileId) -> ()
    
    func makeContextualMenu() -> [ContextualMenu] {
        BlockFileContextualMenuBuilder.contextualMenu(fileData: fileData)
    }
    
    func handle(action: ContextualMenu) {
        switch action {
        case .replace:
            showFilePicker(blockId)
        case .download:
            downloadFile(fileData.metadata.hash)
        default:
            contextualMenuHandler.handle(action: action, info: information)
        }
    }
    
    func didSelectRowInTableView() {
        switch fileData.state {
        case .done:
            downloadFile(fileData.metadata.hash)
        case .empty, .error:
            showFilePicker(blockId)
        case .uploading:
            return
        }
    }
    
    func makeContentConfiguration() -> UIContentConfiguration {
        switch fileData.state {
        case .empty:
            return emptyViewConfiguration(state: .default)
        case .uploading:
            return emptyViewConfiguration(state: .uploading)
        case .error:
            return emptyViewConfiguration(state: .error)
        case .done:
            return BlockFileConfiguration(fileData.mediaData)
        }
    }
    
    private func emptyViewConfiguration(state: BlocksFileEmptyViewState) -> UIContentConfiguration {
        BlocksFileEmptyViewConfiguration(
            image: UIImage.blockFile.empty.file,
            text: "Upload a file",
            state: state
        )
    }
}
