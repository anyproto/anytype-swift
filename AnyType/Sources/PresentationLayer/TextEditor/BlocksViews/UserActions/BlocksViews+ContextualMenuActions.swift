//
//  BlocksViews+ContextualMenuActions.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 21.05.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Resources
extension BlocksViews.ContextualMenu.MenuAction {
    struct Resources {
        typealias Action = BlocksViews.ContextualMenu.MenuAction.Action
        struct Title {
            static func title(for action: Action) -> String {
                switch action {
                case .general(.delete): return "Delete"
                case .general(.duplicate): return "Duplicate"
                case .general(.moveTo): return "Move To"
                case let .specific(value):
                    switch value {
                    case .text(.turnInto): return "Turn Into"
                    case .text(.style): return "Style"
                    case .text(.color): return "Color"
                    case .text(.backgroundColor): return "BackgroundColor"
                    }
                }
            }
        }
        struct Image {
            static func imagePath(for action: Action) -> String {
                switch action {
                case .general(.delete): return "TextEditor/ContextMenu/General/delete"
                case .general(.duplicate): return "TextEditor/ContextMenu/General/duplicate"
                case .general(.moveTo): return "TextEditor/ContextMenu/General/moveTo"
                case let .specific(value):
                    switch value {
                    case .text(.turnInto): return "TextEditor/ContextMenu/Specific/turnInto"
                    case .text(.style): return "TextEditor/ContextMenu/Specific/style"
                    case .text(.color): return ""
                    case .text(.backgroundColor): return ""
                    }
                }
            }
        }
        struct IdentifierBuilder {
            typealias Identifier = String
            static let identifiersAndActions: [String: Action] = [
                ".general(.delete)": .general(.delete),
                ".general(.duplicate)": .general(.duplicate),
                ".general(.moveTo)": .general(.moveTo),
                ".specific(.text(.turnInto))": .specific(.text(.turnInto)),
                ".specific(.text(.style))": .specific(.text(.style)),
                ".specific(.text(.color))": .specific(.text(.color)),
                ".specific(.text(.backgroundColor))": .specific(.text(.backgroundColor))
            ]
            
            static func identifier(for action: Action) -> Identifier {
                switch action {
                case .general(.delete): return ".general(.delete)"
                case .general(.duplicate): return ".general(.duplicate)"
                case .general(.moveTo): return ".general(.moveTo)"
                case let .specific(value):
                    switch value {
                    case .text(.turnInto): return ".specific(.text(.turnInto))"
                    case .text(.style): return ".specific(.text(.style))"
                    case .text(.color): return ".specific(.text(.color))"
                    case .text(.backgroundColor): return ".specific(.text(.backgroundColor))"
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
        case delete
        case duplicate
        case moveTo
    }
}

// MARK:
extension BlocksViews.ContextualMenu.MenuAction.Action {
    enum SpecificAction {
        case text(TextAction)
    }
}

extension BlocksViews.ContextualMenu.MenuAction.Action.SpecificAction {
    enum TextAction {
        case turnInto
        case style
        case color
        case backgroundColor
    }
}
