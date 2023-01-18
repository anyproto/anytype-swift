import Combine
import BlocksModels
import AnytypeCore
import SwiftUI

final class HomeCellDataBuilder {
    
    private let document: BaseDocumentProtocol
    
    init(document: BaseDocumentProtocol) {
        self.document = document
    }
    
    // MARK: - Public
    
    func buildCellData(_ detail: ObjectDetails) -> HomeCellData {
        HomeCellData.create(details: detail)
    }
    
    func buildFavoritesData() -> [HomeCellData] {
        return document.children.compactMap { info in
            guard case .link(let link) = info.content else {
                anytypeAssertionFailure(
                    "Not link type in home screen dashboard: \(info.content)",
                    domain: .homeView
                )
                return nil
            }
            
            guard let details = ObjectDetailsStorage.shared.get(id: link.targetBlockID) else { return nil }
            return HomeCellData.create(details: details, id: info.id)
        }
    }
}
