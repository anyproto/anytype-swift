import BlocksModels
import UIKit

struct VideoBlockViewModel: BlockViewModelProtocol {
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
    
    let showVideoPicker: (BlockId) -> ()
    let downloadVideo: (FileId) -> ()
    
    func makeContentConfiguration() -> UIContentConfiguration {
        VideoBlockConfiguration(fileData: fileData)
    }
    
    func didSelectRowInTableView() {
        switch fileData.state {
        case .empty, .error:
            showVideoPicker(blockId)
        case .uploading, .done:
            return
        }
    }
    
    func makeContextualMenu() -> ContextualMenu {
        BlockFileContextualMenuBuilder.contextualMenu(fileData: fileData)
    }
    
    func handle(action: ContextualMenuAction) {
        switch action {
        case .replace:
            showVideoPicker(blockId)
        case .download:
            downloadVideo(fileData.metadata.hash)
        default:
            contextualMenuHandler.handle(action: action, info: information)
        }
    }
    
    func updateView() { }
}
