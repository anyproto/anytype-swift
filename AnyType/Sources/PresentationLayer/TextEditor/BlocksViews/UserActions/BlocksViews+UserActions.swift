import Foundation
import Combine


// MARK: - UserAction

extension BlocksViews {
    typealias TextContent = String

    /// Top-level user action.
    /// All parsing is starting from this enumeration.
    enum UserAction {
        /// Specific action for each specific blocks views type.
        /// You should define a `.UserAction` payload enumeration in each namespace.
        /// After that you could add it as an entry of this enum.
        enum SpecificAction {
            case file(File.FileAction)
            case page(Page.UserAction)
        }

        case toolbars(ToolbarOpenAction)
        case specific(SpecificAction)
    }
}

// MARK: - ToolbarOpenAction

extension BlocksViews.UserAction {
    /// Toolbar Open action.
    /// When you would like to open specific toolbar, you should add new entry in enumeration.
    /// After that you need to process this entry in specific ToolbarRouter.
    enum ToolbarOpenAction: Equatable {
        static func == (lhs: BlocksViews.UserAction.ToolbarOpenAction, rhs: BlocksViews.UserAction.ToolbarOpenAction) -> Bool {
            switch (lhs, rhs) {
            case (.addBlock, .addBlock): return true
            case (.turnIntoBlock, .turnIntoBlock): return true
            default: return false
            }
        }
        
        case addBlock(AddBlock)
        case turnIntoBlock(TurnIntoBlock)
        case bookmark(Bookmark)
        case marksPane(MarksPane)
    }
}

// MARK: - Blocks / AddBlock and TurnInto

extension BlocksViews.UserAction.ToolbarOpenAction {
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

extension BlocksViews.UserAction.ToolbarOpenAction {
    struct Bookmark {
        typealias Input = Void
        typealias Output = PassthroughSubject<BlocksViews.Toolbar.UnderlyingAction, Never>
        var output: Output
        var input: Input?
    }
}

// MARK: - Marks Pane

extension BlocksViews.UserAction.ToolbarOpenAction {
    enum MarksPane {
        case setTextColor(TextColor)
        case setBackgroundColor(BackgroundColor)
        case setStyle(Style)
        case mainPane(MainPane)
    }
}

extension BlocksViews.UserAction.ToolbarOpenAction.MarksPane {
    struct MainPane {
        typealias Output = PassthroughSubject<MarksPane.Main.Action, Never>
        struct Input {
            var userResponse: MarksPane.Main.RawUserResponse?
            var section: MarksPane.Main.Section.Category?
            
            /// Connect output to input.
            ///
            /// It means that if you want to keep GUI in consistency, you have to provide full cycle from GUI to Model and backward.
            /// However, you could cheat a bit.
            /// You could connect output from this GUI to its input.
            var shouldPluginOutputIntoInput: Bool = false
        }
        var output: Output
        var input: Input?
    }
}

import UIKit
extension BlocksViews.UserAction.ToolbarOpenAction.MarksPane {
    struct TextColor {
        typealias Output = PassthroughSubject<BlocksViews.Toolbar.UnderlyingAction, Never>
        var output: Output
        var input: UIColor?
    }
    
    struct BackgroundColor {
        typealias Output = PassthroughSubject<BlocksViews.Toolbar.UnderlyingAction, Never>
        var output: Output
        var input: UIColor?
    }
    
    struct Style {
        typealias Output = PassthroughSubject<BlocksViews.Toolbar.UnderlyingAction, Never>
        typealias Input = MarksPane.Panes.StylePane.UserResponse
        var output: Output
        var input: Input?
    }
}
