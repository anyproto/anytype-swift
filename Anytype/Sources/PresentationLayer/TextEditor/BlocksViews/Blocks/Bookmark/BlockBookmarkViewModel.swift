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
    
    private let contextualMenuHandler: DefaultContextualMenuHandler
    private let imageLoader = BookmarkImageLoader()
    private let bookmarkData: BlockBookmark
    
    private let showBookmarkBar: (BlockInformation) -> ()
    private let openUrl: (URL) -> ()
    
    init(
        indentationLevel: Int,
        information: BlockInformation,
        bookmarkData: BlockBookmark,
        contextualMenuHandler: DefaultContextualMenuHandler,
        showBookmarkBar: @escaping (BlockInformation) -> (),
        openUrl: @escaping (URL) -> ()
    ) {
        self.indentationLevel = indentationLevel
        self.information = information
        self.bookmarkData = bookmarkData
        self.contextualMenuHandler = contextualMenuHandler
        self.showBookmarkBar = showBookmarkBar
        self.openUrl = openUrl
        
        setup(BlockBookmarkConverter.asResource(bookmarkData))
    }
    
    func makeContentConfiguration() -> UIContentConfiguration {
        BlockBookmarkConfiguration(bookmarkData: bookmarkData, imageLoader: imageLoader)
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
                .init(action: .delete),
                .init(action: .duplicate),
            ]
        )
    }
    
    func handle(action: ContextualMenuAction) {
        contextualMenuHandler.handle(action: action, info: information)
    }
    
    func updateView() { }
    
    private func setup(_ resource: BlockBookmarkResource) {
        guard case let .fetched(payload) = resource.state else {
            return
        }
        
        payload.imageHash.flatMap {
            imageLoader.subscribeImage($0)
        }
        
        payload.iconHash.flatMap {
            imageLoader.subscribeIcon($0)
        }
    }
}
