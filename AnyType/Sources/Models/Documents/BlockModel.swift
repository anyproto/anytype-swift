//
//  BlockModel.swift
//  AnyType
//
//  Created by Denis Batvinkin on 20.09.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Foundation

enum BlockType {
    case text(Text)
    case image(Image)
    case video(Video)
}

extension BlockType {
    
    struct Text {
        enum ContentType {
            case text
            case header
            case quote
            case todo
            case bulleted
            case numbered
            case toggle
            case callout
        }
        
        var text: String
        var contentType: ContentType
    }
}

extension BlockType {
    struct Image {
        enum ContentType {
            case image
            case pageIcon
        }
        var path: URL?
        var contentType: ContentType
    }
}

extension BlockType {
    
    struct Video {
        enum ContentType {
            case video
        }
        var path: URL?
        var contentType: ContentType
    }
    
}

struct Block: Identifiable {
    var id: String
    var parentId: String
    var type: BlockType
}

// MARK: Mocking
extension Block {
    static func mock(_ contentType: BlockType) -> Self {
        return .init(id: UUID().uuidString, parentId: "", type: contentType)
    }
    static func mockText(_ type: BlockType.Text.ContentType) -> Self {
        return .mock(.text(.init(text: "", contentType: type)))
    }
    static func mockImage(_ type: BlockType.Image.ContentType) -> Self {
        return .mock(.image(.init(contentType: type)))
    }
    static func mockVideo(_ type: BlockType.Video.ContentType) -> Self {
        return .mock(.video(.init(contentType: type)))
    }
}
