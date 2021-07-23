import Combine
import BlocksModels
import UIKit

struct BlockBookmarkViewModel: BlockViewModelProtocol {    
    var diffable: AnyHashable {
        [
            blockId,
            bookmarkData,
            indentationLevel
        ] as [AnyHashable]
    }
    
    let indentationLevel: Int
    
    let information: BlockInformation
    let bookmarkData: BlockBookmark
    
    let handleContextualMenu: (ContextualMenu, BlockInformation) -> ()
    let showBookmarkBar: (BlockInformation) -> ()
    let openUrl: (URL) -> ()
    
    func makeContentConfiguration() -> UIContentConfiguration {
        BlockBookmarkConfiguration(state: bookmarkData.blockBookmarkState)
    }
    
    func didSelectRowInTableView() {
        guard let url = URL(string: bookmarkData.url) else {
            showBookmarkBar(information)
            return
        }
        
        openUrl(url)
    }

    func makeContextualMenu() -> [ContextualMenu] {
        [ .addBlockBelow, .duplicate, .delete ]
    }
    
    func handle(action: ContextualMenu) {
        handleContextualMenu(action, information)
    }
}
