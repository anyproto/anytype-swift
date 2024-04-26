import Foundation
import Services
import Combine

extension BaseDocumentProtocol {
    
    var widgetsPublisher: AnyPublisher<[BlockInformation], Never> {
       syncPublisher
            .map { [weak self] _ -> [BlockInformation] in
                guard let self = self else { return [] }
                return self.children.filter(\.isWidget)
            }
            .receiveOnMain()
            .eraseToAnyPublisher()
    }
    
    func targetObjectIdByLinkFor(widgetBlockId: BlockId) -> String? {
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
            return BlockWidgetInfo(block: widget, source: .library(anytypeWidgetId))
        }

        if let contentDetails = detailsStorage.get(id: link.targetBlockID) {
            return BlockWidgetInfo(block: widget, source: .object(contentDetails))
        }
        
        return nil
    }
}
