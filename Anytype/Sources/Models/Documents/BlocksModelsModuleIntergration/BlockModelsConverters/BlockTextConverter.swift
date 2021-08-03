import Foundation
import BlocksModels
import ProtobufMessages


final class BlockTextContentTypeConverter {
    static func asModel(_ value: Anytype_Model_Block.Content.Text.Style) -> BlockText.Style? {
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
        
        case .description_: return .description
        case .UNRECOGNIZED: return nil
        }
    }
    
    static func asMiddleware(_ value: BlockText.Style) -> Anytype_Model_Block.Content.Text.Style {
        switch value {
        case .title: return .title
        case .description: return .description_
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
