import Foundation
import BlocksModels
import SwiftProtobuf
import UIKit
import AnytypeCore

#warning("TODO R: think about working with relationViewModels inssted of Relations")
final class RelationsListViewModel: ObservableObject {
    
    // MARK: - Private variables
    
    @Published private(set) var sections: [RelationsSection]
    private let sectionsBuilder = RelationsSectionBuilder()
    private let relationsService: RelationsServiceProtocol 
    
    private let onValueEditingTap: (String) -> ()
    
    // MARK: - Initializers
    
    init(
        relationsService: RelationsServiceProtocol,
        sections: [RelationsSection] = [],
        onValueEditingTap: @escaping (String) -> ()
    ) {
        self.relationsService = relationsService
        self.sections = sections
        self.onValueEditingTap = onValueEditingTap
    }
    
    // MARK: - Internal functions
    
    func update(with parsedRelations: ParsedRelations) {
        self.sections = sectionsBuilder.buildSections(from: parsedRelations)
    }
    
    func changeRelationFeaturedState(relationId: String) {
        let relationsRowData: [Relation] = sections.flatMap { $0.relations }
        let relationRowData = relationsRowData.first { $0.id == relationId }
        
        guard let relationRowData = relationRowData else { return }
        
        if relationRowData.isFeatured {
            relationsService.removeFeaturedRelation(relationKey: relationRowData.id)
        } else {
            relationsService.addFeaturedRelation(relationKey: relationRowData.id)
        }
    }
    
    func removeRelation(id: String) {
        relationsService.removeRelation(relationKey: id)
    }
    
    func editRelation(id: String) {
        guard FeatureFlags.relationsEditing else { return }
        
        let flattenRelations: [Relation] = sections.flatMap { $0.relations }
        let relation = flattenRelations.first { $0.id == id }
        
        guard
            let relation = relation,
            case .checkbox(let checkbox) = relation
        else {
            onValueEditingTap(id)
            return
        }
        
        relationsService.updateRelation(relationKey: checkbox.id, value: (!checkbox.value).protobufValue)
    }
    
}
