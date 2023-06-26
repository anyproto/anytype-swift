import Foundation
import Combine
import Services

extension BaseDocumentProtocol {
    func widgetTargetDetailsPublisher(widgetBlockId: String) -> AnyPublisher<ObjectDetails, Never> {
        syncPublisher
            .compactMap { [self] _ -> ObjectDetails? in
                guard let targetObjectId = targetObjectIdByLinkFor(widgetBlockId: widgetBlockId) else { return nil }
                return detailsStorage.get(id: targetObjectId)
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}
