import Foundation
import BlocksModels
import SwiftProtobuf
import UIKit

final class ObjectRelationsViewModel: ObservableObject {
    
    // MARK: - Private variables
    
    @Published private(set) var rowViewModels: [ObjectRelationRowViewModel]
    private let viewModelBuilder = ObjectRelationRowViewModelBuilder()
    
    // MARK: - Initializers
    
    init(rowViewModels: [ObjectRelationRowViewModel] = []) {
        self.rowViewModels = rowViewModels
    }
    
    // MARK: - Internal functions
    
    func update(
        with relations: [Relation],
        objectId: String,
        detailsStorage: ObjectDetailsStorageProtocol
    ) {
        let visibleRelations = relations.filter { !$0.isHidden }
        
        self.rowViewModels = viewModelBuilder.buildViewModels(
            using: visibleRelations,
            objectId: objectId,
            detailsStorage: detailsStorage
        )
    }
    
}
