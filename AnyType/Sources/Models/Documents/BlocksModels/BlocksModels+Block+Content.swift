//
//  BlocksModels+Block+Content.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 03.06.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation

extension BlocksModels.Block {
    enum Content {}
}

///
extension BlocksModels.Block.Content {
    enum ContentType {
        case text(Text)
        case smartblock(Smartblock)
        case file(File)
        case div(Div)
        case bookmark(Bookmark)
        case link(Link)
    }
}

extension BlocksModels.Block.Content.ContentType {
    struct Text {
        enum ContentType {
            case text
            case header
            case header2
            case header3
            case header4
            case quote
            case todo
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
        var fields: Dictionary<String, Any>
    }
}
