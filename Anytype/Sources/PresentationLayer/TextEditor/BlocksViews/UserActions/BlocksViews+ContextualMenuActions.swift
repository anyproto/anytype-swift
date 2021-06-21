import Foundation
import UIKit

// MARK: - Resources
extension BlocksViews.ContextualMenu.MenuAction {
    struct Resources {
        typealias Action = BlocksViews.ContextualMenu.MenuAction.Action
        struct Title {
            private static func resourceKey(for action: Action) -> String {
                switch action {
                case .general(.addBlockBelow): return "General.AddBlockBelow"
                case .general(.delete): return "General.Delete"
                case .general(.duplicate): return "General.Duplicate"
                case .general(.moveTo): return "General.MoveTo"
                case let .specific(value):
                    switch value {
                    case .turnIntoPage: return "Specific.TurnIntoPage"
                    case .style: return "Specific.Style"
                    case .color: return "Specific.Color"
                    case .backgroundColor: return "Specific.BackgroundColor"
                    case .download: return "Specific.Download"
                    case .replace: return "Specific.Replace"
                    case .addCaption: return "Specific.AddCaption"
                    case .rename: return "Specific.Rename"
                    }
                }
            }
            static func title(for action: Action) -> String {
                NSLocalizedString(self.resourceKey(for: action), tableName: "TextEditor.ContextualMenu.Actions", bundle: .main, value: "", comment: "")
            }
        }
        struct Image {
            static func imagePath(for action: Action) -> String {
                switch action {
                case .general(.addBlockBelow): return "TextEditor/ContextMenu/General/addBlockBelow"
                case .general(.delete): return "TextEditor/ContextMenu/General/delete"
                case .general(.duplicate): return "TextEditor/ContextMenu/General/duplicate"
                case .general(.moveTo): return "TextEditor/ContextMenu/General/moveTo"
                case let .specific(value):
                    switch value {
                    case .turnIntoPage: return "TextEditor/ContextMenu/Specific/turnInto"
                    case .style: return "TextEditor/ContextMenu/Specific/style"
                    case .color: return ""
                    case .backgroundColor: return ""
                    case .download: return "TextEditor/ContextMenu/Specific/download"
                    case .replace: return "TextEditor/ContextMenu/Specific/replace"
                    case .addCaption: return "TextEditor/ContextMenu/Specific/addCaption"
                    case .rename: return "TextEditor/ContextMenu/Specific/rename"
                    }
                }
            }
        }
        struct IdentifierBuilder {
            typealias Identifier = String
            static var identifiersAndActions: [String: Action] = .init(uniqueKeysWithValues: [
                .general(.addBlockBelow),
                .general(.delete),
                .general(.duplicate),
                .general(.moveTo),
                .specific(.turnIntoPage),
                .specific(.style),
                .specific(.color),
                .specific(.backgroundColor),
                .specific(.download),
                .specific(.replace),
                .specific(.addCaption),
                .specific(.rename)
            ].map({(Self.identifier(for: $0), $0)}))
            
            static func identifier(for action: Action) -> Identifier {
                switch action {
                case .general(.addBlockBelow): return ".general(.addBlockBelow)"
                case .general(.delete): return ".general(.delete)"
                case .general(.duplicate): return ".general(.duplicate)"
                case .general(.moveTo): return ".general(.moveTo)"
                case let .specific(value):
                    switch value {
                    case .turnIntoPage: return ".specific(.turnIntoPage)"
                    case .style: return ".specific(.style)"
                    case .color: return ".specific(.color)"
                    case .backgroundColor: return ".specific(.backgroundColor)"
                    case .download: return ".specifc(.download)"
                    case .replace: return ".specific(.replace)"
                    case .addCaption: return ".specific(.addCaption)"
                    case .rename: return ".specific(.rename)"
                    }
                }
            }
            
            static func action(for identifier: Identifier) -> Action? {
                self.identifiersAndActions[identifier]
            }
        }
    }
}

// MARK: Payload Builder
extension BlocksViews.ContextualMenu.MenuAction {
    enum PayloadBuilder {
        static func payload(for action: Action) -> Payload {
            .init(title: Resources.Title.title(for: action), imagePath: Resources.Image.imagePath(for: action), image: nil)
        }
    }
}

// MARK: Contextual Menu

extension BlocksViews {
    struct ContextualMenu {
        var title: String = ""
        var children: [MenuAction] = []
    }
}

extension BlocksViews.ContextualMenu {
    
    struct MenuAction {
        struct Payload {
            var title: String = ""
            var imagePath: String = ""
            var image: UIImage?
            public var currentImage: UIImage? {
                self.image ?? UIImage.init(named: self.imagePath)
            }
        }
        
        enum Action {
            case general(GeneralAction)
            case specific(SpecificAction)
        }
        
        var payload: Payload
        var identifier: String?
        var action: Action
        var children: [MenuAction] = []
        
        internal init(payload: Payload, action: Action, children: [MenuAction] = []) {
            self.payload = payload
            self.action = action
            self.identifier = Resources.IdentifierBuilder.identifier(for: action)
            self.children = children
        }
        
        static func create(action: Action, children: [MenuAction] = []) -> Self {
            .init(payload: PayloadBuilder.payload(for: action), action: action, children: children)
        }
    }
}

// MARK: General Actions ( For all blocks )
extension BlocksViews.ContextualMenu.MenuAction.Action {
    enum GeneralAction {
        case addBlockBelow
        case delete
        case duplicate
        case moveTo
    }
}

// MARK:
extension BlocksViews.ContextualMenu.MenuAction.Action {
    enum SpecificAction {
        case turnIntoPage
        /// Text
        case style
        case color
        case backgroundColor
        
        /// Files
        case download
        case replace
        
        /// Image
        case addCaption
        
        /// Page
        case rename
    }
}
