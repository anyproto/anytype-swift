import Foundation
import BlocksModels
import SwiftProtobuf
import UIKit

final class ObjectRelationsViewModel: ObservableObject {
    
    // MARK: - Private variables
    
    @Published private(set) var sections: [ObjectRelationsSection]
    private let sectionsBuilder = ObjectRelationsSectionBuilder()
    
    // MARK: - Initializers
    
    init(sections: [ObjectRelationsSection] = []) {
        self.sections = sections
    }
    
    // MARK: - Internal functions
    
    func update(
        with relations: [Relation],
        objectId: String,
        detailsStorage: ObjectDetailsStorageProtocol
    ) {
        let visibleRelations = relations.filter { !$0.isHidden }
        
        self.sections = sectionsBuilder.buildViewModels(
            using: visibleRelations,
            objectId: objectId,
            detailsStorage: detailsStorage
        )
    }
    
}
