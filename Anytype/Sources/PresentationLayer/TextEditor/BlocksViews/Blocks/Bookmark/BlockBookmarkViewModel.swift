import Combine
import BlocksModels
import UIKit

struct BlockBookmarkViewModel: BlockViewModelProtocol {
    let isStruct = true
    
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
    
    let contextualMenuHandler: DefaultContextualMenuHandler
    
    let showBookmarkBar: (BlockInformation) -> ()
    let openUrl: (URL) -> ()
    
    func makeContentConfiguration() -> UIContentConfiguration {
        BlockBookmarkConfiguration(bookmarkData: bookmarkData)
    }
    
    func didSelectRowInTableView() {
        guard let url = URL(string: bookmarkData.url) else {
            showBookmarkBar(information)
            return
        }
        
        openUrl(url)
    }

    func makeContextualMenu() -> ContextualMenu {
        ContextualMenu(
            title: "",
            children: [
                .init(action: .addBlockBelow),
                .init(action: .duplicate),
                .init(action: .delete),
            ]
        )
    }
    
    func handle(action: ContextualMenuAction) {
        contextualMenuHandler.handle(action: action, info: information)
    }
    
    func updateView() { }
}
