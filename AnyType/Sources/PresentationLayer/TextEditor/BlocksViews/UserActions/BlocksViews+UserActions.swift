import Foundation
import Combine

extension BlocksViews {
    enum UserAction {
        case file(File.FileAction)
        case page(Page.UserAction)
        
        case addBlock(AddBlock)
        case turnIntoBlock(TurnIntoBlock)
        case bookmark(Bookmark)
    }
}

// MARK: - Blocks / AddBlock and TurnInto

extension BlocksViews.UserAction {
    struct BlockMenu {
        struct Payload {
            typealias Filtering = BlocksViews.Toolbar.AddBlock.ViewModel.BlocksTypesCasesFiltering
            var filtering: Filtering
        }
        var payload: Payload
    }
    
    struct AddBlock {
        typealias Input = BlockMenu
        typealias Output = PassthroughSubject<BlocksViews.Toolbar.UnderlyingAction, Never>
        var output: Output
        var input: Input?
    }
    
    struct TurnIntoBlock {
        typealias Input = BlockMenu
        typealias Output = PassthroughSubject<BlocksViews.Toolbar.UnderlyingAction, Never>
        var output: Output
        var input: Input?
    }
}

// MARK: - Bookmark

extension BlocksViews.UserAction {
    struct Bookmark {
        typealias Input = Void
        typealias Output = PassthroughSubject<BlocksViews.Toolbar.UnderlyingAction, Never>
        var output: Output
        var input: Input?
    }
}
