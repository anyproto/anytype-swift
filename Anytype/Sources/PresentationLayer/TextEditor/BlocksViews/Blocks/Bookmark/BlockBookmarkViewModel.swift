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
        let state = bookmarkData.blockBookmarkState
        switch state {
        case .empty:
            return BlocksFileEmptyViewConfiguration(
                image: UIImage.blockFile.empty.bookmark,
                text: "Add a web bookmark".localized,
                state: .default
            )
        case let .fetched(payload):
            return BlockBookmarkConfiguration(state: .fetched(payload))
        case let .onlyURL(url):
            return BlockBookmarkConfiguration(state: .onlyURL(url))
        }
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
