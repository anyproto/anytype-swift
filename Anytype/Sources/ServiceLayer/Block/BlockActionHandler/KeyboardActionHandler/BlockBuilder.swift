import BlocksModels
import AnytypeCore
import SwiftUI

struct BlockBuilder {    
    static func createNewBlock(type: BlockContentType) -> BlockInformation? {
        guard let content = createContent(type: type) else { return nil }
        
        let info = BlockInformation.empty(content: content)
        
        if case .file(let blockFile) = content, case .image = blockFile.contentType {
            return info.updated(alignment: .center)
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
        case let .file(type):
            return .file(.empty(contentType: type))
        case .link:
            return .link(.empty())
        case let .relation(key: key):
            return .relation(.init(key: key))
        case .layout, .smartblock, .featuredRelations, .dataView:
            anytypeAssertionFailure("Unsupported type \(type)", domain: .blockBuilder)
            return nil
        }
    }
}
