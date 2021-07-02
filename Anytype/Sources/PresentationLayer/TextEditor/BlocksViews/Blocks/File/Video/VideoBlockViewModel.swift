import BlocksModels
import UIKit

struct VideoBlockViewModel: BlockViewModelProtocol {
    let isStruct = true
    
    var diffable: AnyHashable {
        fileData
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
        guard fileData.state == .done else {
            return
        }
        
        showVideoPicker(blockId)
    }
    
    func makeContextualMenu() -> ContextualMenu {
        switch fileData.state {
        case .done:
            return .init(title: "", children: [
                .init(action: .addBlockBelow),
                .init(action: .delete),
                .init(action: .duplicate),
                .init(action: .download),
                .init(action: .replace)
            ])
        default:
            return .init(title: "", children: [
                .init(action: .addBlockBelow),
                .init(action: .delete),
                .init(action: .duplicate),
            ])
        }
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
