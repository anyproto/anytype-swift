//
//  Block+Content.swift
//  BlocksModels
//
//  Created by Dmitry Lobanov on 10.07.2020.
//  Copyright © 2020 Dmitry Lobanov. All rights reserved.
//

import Foundation

fileprivate typealias Namespace = Block.Content

public extension Block {
    enum Content {}
}

///
public extension Namespace {
    enum ContentType {
        case smartblock(Smartblock)
        case text(Text)
        case file(File)
        case div(Div)
        case bookmark(Bookmark)
        case link(Link)
    }
}

/// ContentType / Cases
public extension Namespace.ContentType {
    var kind: Kind { .init(attribute: self, strategy: .topLevel) }
    var deepKind: Kind { .init(attribute: self, strategy: .levelOne) }
}

public extension Namespace.ContentType {
    struct KindComparator: Equatable {
        fileprivate enum Strategy {
            case topLevel
            case levelOne
            func same(_ lhs: Element, _ rhs: Element) -> Bool {
                switch self {
                case .topLevel:
                    switch (lhs, rhs) {
                    case (.text, .text): return true
                    case (.smartblock, .smartblock): return true
                    case (.file, .file): return true
                    case (.div, .div): return true
                    case (.bookmark, .bookmark): return true
                    case (.link, .link): return true
                    default: return false
                    }
                case .levelOne:
                    guard Strategy.topLevel.same(lhs, rhs) else {
                        return false
                    }
                    switch (lhs, rhs) {
                    case let (.text(left), .text(right)): return left.contentType == right.contentType
                    default: return true
                    }
                }
            }
        }
        
        typealias Element = Block.Content.ContentType
        
        var attribute: Element
        fileprivate var strategy: Strategy = .topLevel
        
        func sameKind(_ value: Element) -> Bool {
            self.same(self.attribute, value)
        }
        func sameKind(_ value: Kind) -> Bool {
            self.same(self.attribute, value.attribute)
        }
        func same(_ lhs: Element, _ rhs: Element) -> Bool {
            self.strategy.same(lhs, rhs)
        }
        
        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.sameKind(rhs)
        }
    }
    
    typealias Kind = KindComparator
}

// MARK: ContentType / Text
public extension Namespace.ContentType {
    struct Text {
        public var attributedText: NSAttributedString
        public var color: String = ""
        public var contentType: ContentType
        
        // MARK: - Memberwise initializer
        public init(attributedText: NSAttributedString, color: String = "", contentType: Block.Content.ContentType.Text.ContentType) {
            self.attributedText = attributedText
            self.color = color
            self.contentType = contentType
        }
    }
}

// MARK: ContentType / Text / Supplements
public extension Namespace.ContentType.Text {
    init(contentType: ContentType) {
        self.init(attributedText: .init(), contentType: contentType)
    }
            
    // MARK: - Create
    static func empty() -> Self {
        self.createDefault(text: "")
    }
    static func createDefault(text: String) -> Self {
        .init(attributedText: .init(string: text), contentType: .text)
    }
}

// MARK: ContentType / Text / ContentType
public extension Namespace.ContentType.Text {
    enum ContentType {
        case text
        case header
        case header2
        case header3
        case header4
        case quote
        case checkbox
        case bulleted
        case numbered
        case toggle
        case callout
    }
}

// MARK: ContentType / Smartblock
public extension Namespace.ContentType {
    struct Smartblock {
        public var style: Style = .page
        
        // MARK: - Memberwise initializer
        public init(style: Block.Content.ContentType.Smartblock.Style = .page) {
            self.style = style
        }
    }
}

// MARK: ContentType / Smartblock / Style
public extension Namespace.ContentType.Smartblock {
    enum Style {
        case page
        case home
        case profilePage
        case archive
        case breadcrumbs
    }
}

// MARK: ContentType / File
public extension Namespace.ContentType {
    struct File {
        public var name: String
        public var hash: String
        public var state: State
        public var contentType: ContentType
        public var mime: String

        // MARK: - Memberwise initializer
        public init(name: String, hash: String, state: Block.Content.ContentType.File.State, contentType: Block.Content.ContentType.File.ContentType, mime: String) {
            self.name = name
            self.hash = hash
            self.state = state
            self.contentType = contentType
            self.mime = mime
        }
    }
}

// MARK: ContentType / File / ContentType
public extension Namespace.ContentType.File {
    enum ContentType {
        case none
        case file
        case image
        case video
    }
}

// MARK: ContentType / File / State
public extension Namespace.ContentType.File {
    enum State {
        /// There is no file and preview, it's an empty block, that waits files.
        case empty
        /// There is still no file/preview, but file already uploading
        case uploading
        /// File exists, uploading is done
        case done
        /// Error while uploading
        case error
    }
}

// MARK: ContentType / Div
public extension Namespace.ContentType {
    // TODO: Add style to Div.
    struct Div {
        // MARK: - Memberwise initializer
        public init() {}
    }
}

// MARK: ContentType / Bookmark
public extension Namespace.ContentType {
    // Bookmark has something, maybe add it later.
    struct Bookmark {
        // MARK: - Memberwise initializer
        public init() {}
    }
}

// MARK: ContentType / Link
public extension Namespace.ContentType {
    struct Link {
        public var targetBlockID: String
        public var style: Style
        public var fields: [String: AnyHashable]
        
        // MARK: - Memberwise initializer
        public init(targetBlockID: String, style: Block.Content.ContentType.Link.Style, fields: [String : AnyHashable]) {
            self.targetBlockID = targetBlockID
            self.style = style
            self.fields = fields
        }
    }
}

// MARK: ContentType / Link / Style
public extension Namespace.ContentType.Link {
    enum Style {
        case page
        case dataview
    }
}

// MARK: - ContentType / Hashable
extension Namespace.ContentType: Hashable {}
extension Namespace.ContentType.Smartblock: Hashable {}
extension Namespace.ContentType.Text: Hashable {}
extension Namespace.ContentType.File: Hashable {}
extension Namespace.ContentType.Div: Hashable {}
extension Namespace.ContentType.Bookmark: Hashable {}
extension Namespace.ContentType.Link: Hashable {}
