import Foundation

extension BaseDocumentProtocol {
    var isDocumentEmpty: Bool {

        let haveNonTextAndRelationBlocks = children.contains {
            switch $0.information.content {
            case .text, .featuredRelations:
                return false
            default:
                return true
            }
        }

        if haveNonTextAndRelationBlocks { return false }

        let textBlocks = children.filter { $0.information.content.isText }

        switch textBlocks.count {
        case 0, 1:
            return true
        case 2:
            return textBlocks.last?.information.content.isEmpty ?? false
        default:
            return false
        }
    }
}
