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
}
