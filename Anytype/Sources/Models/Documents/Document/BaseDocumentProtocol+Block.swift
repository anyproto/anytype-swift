import Foundation

extension BaseDocumentProtocol {
    
    func targetLinkObjectIdFor(blockId: String) -> String? {
        guard let info = infoContainer.get(id: blockId),
              case let .link(link) = info.content else { return nil }
        return link.targetBlockID
    }
}
