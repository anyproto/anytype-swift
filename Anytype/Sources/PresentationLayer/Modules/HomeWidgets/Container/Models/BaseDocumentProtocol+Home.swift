import Foundation
import Services
import Combine

extension BaseDocumentProtocol {
        
    func targetObjectIdByLinkFor(widgetBlockId: String) -> String? {
        guard let block = infoContainer.get(id: widgetBlockId),
              let contentId = block.childrenIds.first,
              let contentInfo = infoContainer.get(id: contentId),
              case let .link(link) = contentInfo.content else { return nil }
        
        return link.targetBlockID
    }
    
    func widgetInfo(blockId: String) -> BlockWidgetInfo? {
        guard let block = infoContainer.get(id: blockId) else { return nil }
        return widgetInfo(block: block)
    }
    
    func widgetInfo(block: BlockInformation) -> BlockWidgetInfo? {
        guard case let .widget(widget) = block.content,
              let contentId = block.childrenIds.first,
              let contentInfo = infoContainer.get(id: contentId),
              case let .link(link) = contentInfo.content else { return nil }
        
        
        if let anytypeWidgetId = AnytypeWidgetId(rawValue: link.targetBlockID) {
            return BlockWidgetInfo(id: block.id, block: widget, source: .library(anytypeWidgetId))
        }

        if let contentDetails = detailsStorage.get(id: link.targetBlockID) {
            return BlockWidgetInfo(id: block.id, block: widget, source: .object(contentDetails))
        }
        
        return nil
    }
    
    func widgetBlockIdFor(targetObjectId: String) -> String? {
        for block in children {
            guard case .widget = block.content,
                  let contentId = block.childrenIds.first,
                  let contentInfo = infoContainer.get(id: contentId),
                  case let .link(link) = contentInfo.content else { continue }
            
            if link.targetBlockID == targetObjectId {
                return block.id
            }
        }
        
        return nil
    }
}
