import UIKit
import BlocksModels
import Combine

struct BlockFileViewModel: BlockViewModelProtocol {
    let isStruct = true
    
    var diffable: AnyHashable {
        [
            blockId,
            fileData,
            indentationLevel
        ] as [AnyHashable]
    }
    
    let information: BlockInformation
    let fileData: BlockFile
    let indentationLevel: Int
    let contextualMenuHandler: DefaultContextualMenuHandler
    
    let showFilePicker: (BlockId) -> ()
    let downloadFile: (FileId) -> ()
    
    func makeContentConfiguration() -> UIContentConfiguration {
        BlockFileConfiguration(fileData)
    }
    
    func makeContextualMenu() -> ContextualMenu {
        BlockFileContextualMenuBuilder.contextualMenu(fileData: fileData)
    }
    
    func handle(action: ContextualMenuAction) {
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
        guard fileData.state != .uploading else {
            return
        }
        
        showFilePicker(blockId)
    }
    
    func updateView() { }
}
