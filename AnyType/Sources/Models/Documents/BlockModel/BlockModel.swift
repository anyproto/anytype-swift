//
//  BlockModel.swift
//  AnyType
//
//  Created by Denis Batvinkin on 20.09.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Foundation


/// Block type
enum BlockType {
    case text(Text)
    case dashboard(Dashboard)
    case page(Page)
    case dataview(DataView)
    case file(File)
    case layout(Layout)
    case div(Div)
    case bookmark(Bookmark)
    case icon(Icon)
    case link(Link)
}

/// Link block
extension BlockType {
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

/// Icon block
extension BlockType {
    struct Icon {
        var name: String
    }
}


/// Bookmark block
extension BlockType {
    struct Bookmark {
    }
}

/// Div block
extension BlockType {
    struct Div {
    }
}

/// Layout block
extension BlockType {
    struct Layout {
        enum Style {
            case row
            case column
        }
        var style: Style
    }
}

/// File block
extension BlockType {
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
}


/// Dataview block
extension BlockType {
    struct DataView {
    }
}

/// Text block
extension BlockType {
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
        
        var text: String
        var contentType: ContentType
    }
}

/// Dashboard block
extension BlockType {
    struct Dashboard {
        enum Style {
            case mainScreen
            case archive
        }
        var style: Style
    }
}

/// Page block
extension BlockType {
    struct Page {
        enum Style {
            /// Ordinary page, without additional fields
            case empty
            /// Page with a task fields
            case task
            /// Page, that organize a set of blocks by a specific criterio
            case set
        }
        var style: Style
    }
}
