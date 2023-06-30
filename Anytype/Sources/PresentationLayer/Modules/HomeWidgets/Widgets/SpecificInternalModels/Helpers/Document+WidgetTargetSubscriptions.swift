import Foundation
import Combine
import Services

extension BaseDocumentProtocol {
    func widgetTargetDetailsPublisher(widgetBlockId: String) -> AnyPublisher<ObjectDetails, Never> {
        syncPublisher
            .compactMap { [weak self] _ -> ObjectDetails? in
                guard let self else { return nil }
                guard let targetObjectId = targetObjectIdByLinkFor(widgetBlockId: widgetBlockId) else { return nil }
                return detailsStorage.get(id: targetObjectId)
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    func blockWidgetInfoPublisher(widgetBlockId: String) -> AnyPublisher<BlockWidgetInfo, Never> {
        syncPublisher
            .compactMap { [weak self] _ -> BlockWidgetInfo? in
                guard let self else { return nil }
                return widgetInfo(blockId: widgetBlockId)
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}
