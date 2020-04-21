//
//  BlocksViews+Toolbar+BlocksTypes.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 20.04.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit

// MARK: BlocksViewsToolbarBlocksTypesProtocol
/// This protocol provides resources getters for each subtype in Category.
///
protocol BlocksViewsToolbarBlocksTypesProtocol {
    var subpath: String {get}
    var path: String {get}
    var title: String {get}
    var subtitle: String {get}
}

extension BlocksViewsToolbarBlocksTypesProtocol {
    var path: String {
        BlocksViews.Toolbar.BlocksTypes.Resources.Image.image(subpath)
    }
    var title: String {
        return self.path.components(separatedBy: "/").last ?? ""
    }
    var subtitle: String {
        ""
    }
}

extension BlocksViews.Toolbar {
    enum BlocksTypes: CaseIterable {
        case text(Text), list(List), page(Page), media(Media), tool(Tool), other(Other)
        static var allCases: [Self] = [.text(.text), .list(.bulleted), .page(.page), .media(.bookmark), .other(.divider)]
    }
}

// MARK: Internals
extension BlocksViews.Toolbar.BlocksTypes {
    enum Text: CaseIterable {
        case text, h1, h2, h3, highlighted
        static var allCases: [Self] = [.text, .h1, .h2, .h3, .highlighted]
    }

    enum List: CaseIterable {
        case bulleted, checkbox, numbered, toggle
        static var allCases: [Self] = [.bulleted, .checkbox, .numbered, .toggle]
    }

    enum Page: CaseIterable {
        case page, existingTool
        static var allCases: [Self] = [.page, .existingTool]
    }

    typealias Objects = Media // TODO: Replace it.
    enum Media: CaseIterable {
        case file, picture, video, bookmark, code
        static var allCases: [Self] = [.file, .picture, .video, .bookmark, .code]
    }

    enum Tool: CaseIterable {
        case contact, database, set, task
        static var allCases: [Self] = [.contact, .database, .set, .task]
    }

    enum Other: CaseIterable {
        case divider, dots
        static var allCases: [Self] = [.divider, dots]
    }
}

// MARK: Identifiable
extension BlocksViews.Toolbar.BlocksTypes: Identifiable {
    var id: String { Resources.Title.title(for: self) }
}

// MARK: Resources
extension BlocksViews.Toolbar.BlocksTypes {
    typealias BlocksTypes = BlocksViews.Toolbar.BlocksTypes
    enum Resources {
        struct Color {
            private static let path = "TextEditor/Toolbar/Blocks/New/Types/TypesColors/"
            static func color(for type: BlocksTypes) -> UIColor {
                switch type {
                case .text: return UIColor.init(named: path + "Text") ?? .clear
                case .list: return UIColor.init(named: path + "List") ?? .clear
                case .page: return UIColor.init(named: path + "Page") ?? .clear
                case .media: return UIColor.init(named: path + "Media") ?? .clear
                case .tool: return UIColor.init(named: path + "Tool") ?? .clear
                case .other: return UIColor.init(named: path + "Other") ?? .clear
                }
            }
//            func callAsFunction(_ type: BlocksTypes) -> UIColor { Self.color(for: type) }
        }
        struct Title {
            static func title(for type: BlocksTypes) -> String {
                switch type {
                case .text: return "Text"
                case .list: return "List"
                case .page: return "Page"
                case .media: return "Objects"
                case .tool: return "Tool"
                case .other: return "Other"
                }
            }
//            func callAsFunction(_ type: BlocksTypes) -> String { Self.title(for: type) }
        }
        struct Image {
            private static let imagesPrefix = "TextEditor/Toolbar/Blocks/New/Types/"
            static func image(_ subpath: String) -> String { imagesPrefix + subpath }
//            func callAsFunction(_ subpath: String) -> String { Self.image(subpath) }
        }
    }
}

extension BlocksViews.Toolbar.BlocksTypes {
    var title: String { Resources.Title.title(for: self) }
}

// MARK: Protocol Adoption / BlocksViewsToolbarBlocksTypesProtocol
extension BlocksViews.Toolbar.BlocksTypes.Text: BlocksViewsToolbarBlocksTypesProtocol {
    var subpath: String {
        switch self {
        case .text: return "Text/Text"
        case .h1: return "Text/H1"
        case .h2: return "Text/H2"
        case .h3: return "Text/H3"
        case .highlighted: return "Text/Highlighted"
        }
    }
    var subtitle: String {
        switch self {
        case .text: return "Just start writing with a plain text"
        case .h1: return "Medium section heading"
        case .h2: return "Small section heading"
        case .h3: return "Small section heading"
        case .highlighted: return "Big section heading"
        }
    }
}

extension BlocksViews.Toolbar.BlocksTypes.List: BlocksViewsToolbarBlocksTypesProtocol {
    var subpath: String {
        switch self {
        case .bulleted: return "List/Bulleted"
        case .checkbox: return "List/Checkbox"
        case .numbered: return "List/Numbered"
        case .toggle: return "List/Toggle"
        }
    }
    var subtitle: String {
        switch self {
        case .bulleted: return ""
        case .checkbox: return ""
        case .numbered: return ""
        case .toggle: return ""
        }
    }
}

extension BlocksViews.Toolbar.BlocksTypes.Page: BlocksViewsToolbarBlocksTypesProtocol {
    var subpath: String {
        switch self {
        case .page: return "Page/Page"
        case .existingTool: return "Page/ExistingPage"
        }
    }
    var title: String {
        switch self {
        case .page: return self.path.components(separatedBy: "/").last ?? ""
        case .existingTool: return "Existing Page"
        }
    }
}

extension BlocksViews.Toolbar.BlocksTypes.Media: BlocksViewsToolbarBlocksTypesProtocol {
    var subpath: String {
        switch self {
        case .file: return "Media/File"
        case .picture: return "Media/Picture"
        case .video: return "Media/Video"
        case .bookmark: return "Media/Bookmark"
        case .code: return "Media/Code"
        }
    }
}

extension BlocksViews.Toolbar.BlocksTypes.Tool: BlocksViewsToolbarBlocksTypesProtocol {
    var subpath: String {
        switch self {
        case .contact: return "Tool/Contact"
        case .database: return "Tool/Database"
        case .set: return "Tool/Set"
        case .task: return "Tool/Task"
        }
    }
}

extension BlocksViews.Toolbar.BlocksTypes.Other: BlocksViewsToolbarBlocksTypesProtocol {
    var subpath: String {
        switch self {
        case .divider: return "Other/Divider"
        case .dots: return "Other/Dots"
        }
    }
}

