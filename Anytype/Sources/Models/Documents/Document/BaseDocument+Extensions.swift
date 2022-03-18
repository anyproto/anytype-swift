import Foundation

extension BaseDocumentProtocol {
    var isDocumentEmpty: Bool {

        let haveNonTextAndRelationBlocks = children.contains {
            switch $0.content {
            case .text, .featuredRelations:
                return false
            default:
                return true
            }
        }

        if haveNonTextAndRelationBlocks { return false }

        let textBlocks = children.filter { $0.content.isText }

        switch textBlocks.count {
        case 0, 1:
            return true
        case 2:
            return textBlocks.last?.content.isEmpty ?? false
        default:
            return false
        }
    }
}
