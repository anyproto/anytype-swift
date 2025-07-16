import Services
import AnytypeCore
import SwiftUI

struct BlockBuilder {    
    static func createNewBlock(type: BlockContentType) -> BlockInformation? {
        guard let content = createContent(type: type) else { return nil }
        
        let info = BlockInformation.empty(content: content)
        
        if case .file(let blockFile) = content, case .image = blockFile.contentType {
            return info.updated(horizontalAlignment: .center)
        }

        return info
    }

    private static func createContent(type: BlockContentType) -> BlockContent? {
        switch type {
        case let .text(style):
            return .text(.empty(contentType: style))
        case .bookmark:
            return .bookmark(.empty())
        case let .divider(style):
            return .divider(.init(style: style))
        case let .file(data):
            return .file(.empty(contentType: data.contentType))
        case .link:
            return .link(.empty())
        case let .relation(key: key):
            return .relation(.init(key: key))
        case .tableOfContents:
            return .tableOfContents
        case .layout, .smartblock, .featuredRelations, .dataView, .widget, .chat:
            anytypeAssertionFailure("Unsupported type", info: ["type": "\(type)"])
            return nil
        case .table:
            return .table
        case .tableColumn:
            return .tableColumn
        case .tableRow:
            return .tableRow(BlockTableRow(isHeader: false))
        case .embed:
            return .embed(BlockLatex())
        }
    }
}
