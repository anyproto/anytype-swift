//
//  BlocksModels+Block+Content.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 03.06.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation

fileprivate typealias Namespace = BlocksModels.Block.Content
extension BlocksModels.Block {
    enum Content {}
}

///
extension Namespace {
    enum ContentType {
        case smartblock(Smartblock)
        case text(Text)
        case file(File)
        case div(Div)
        case bookmark(Bookmark)
        case link(Link)
        
        var kind: Kind { .init(attribute: self, strategy: .topLevel) }
        var deepKind: Kind { .init(attribute: self, strategy: .levelOne) }
    }
}

extension Namespace.ContentType {
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
        
        typealias Element = BlocksModels.Block.Content.ContentType
        
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
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.sameKind(rhs)
        }
    }
    
    typealias Kind = KindComparator
}

extension Namespace.ContentType {
    struct Text {
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
        
        var attributedText: NSAttributedString
        var text: String {
            self.attributedText.string
        }
                
        /// Color of whole block.
        /// Actually, a foreground color.
        ///
        var color: String = ""
        
        var contentType: ContentType
        
        // MARK: - Initialization
        internal init(attributedText: NSAttributedString, contentType: ContentType, color: String = "") {
            self.attributedText = attributedText
            self.contentType = contentType
            self.color = color
        }
        
        internal init(contentType: ContentType) {
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
    
    struct Smartblock {
        // style?
        enum Style {
            case page
            case home
            case profilePage
            case archive
            case breadcrumbs
        }
        var style: Style = .page
    }
    
    struct File {
        enum ContentType {
            case image
            case video
        }
        
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
        
        var name: String
        var hash: String
        var state: State
        var contentType: ContentType
    }
    
    struct Div {} // Div has style, add it later.
    
    struct Bookmark {} // Bookmark has something, maybe add it later.
    
    struct Link {
        enum Style {
            case page
            case dataview
        }
        var targetBlockID: String
        var style: Style
        var fields: [String: AnyHashable]
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
