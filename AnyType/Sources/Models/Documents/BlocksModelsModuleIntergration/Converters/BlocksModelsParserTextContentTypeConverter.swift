import Foundation
import BlocksModels
import ProtobufMessages


final class BlocksModelsParserTextContentTypeConverter {
    typealias Model = BlockContent.Text.ContentType
    typealias MiddlewareModel = Anytype_Model_Block.Content.Text.Style

    static func asModel(_ value: MiddlewareModel) -> Model? {
        switch value {
        case .title: return .title
        case .paragraph: return .text
        case .header1: return .header
        case .header2: return .header2
        case .header3: return .header3
        case .header4: return .header4
        case .quote: return .quote
        case .code: return .code
        case .checkbox: return .checkbox
        case .marked: return .bulleted
        case .numbered: return .numbered
        case .toggle: return .toggle
        default: return nil
        }
    }
    
    static func asMiddleware(_ value: Model) -> MiddlewareModel {
        switch value {
        case .title: return .title
        case .text: return .paragraph
        case .header: return .header1
        case .header2: return .header2
        case .header3: return .header3
        case .header4: return .header4
        case .quote: return .quote
        case .checkbox: return .checkbox
        case .bulleted: return .marked
        case .numbered: return .numbered
        case .toggle: return .toggle
        case .code: return .code
        }
    }
}
