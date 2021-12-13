import Foundation
import BlocksModels
import SwiftProtobuf
import UIKit
import AnytypeCore

final class RelationsListViewModel: ObservableObject {
    
    // MARK: - Private variables
    
    @Published private(set) var sections: [RelationsSection]
    private let sectionsBuilder = RelationsSectionBuilder()
    private let relationsService: RelationsServiceProtocol 
    private let detailsService: DetailsServiceProtocol
    
    private let onValueEditingTap: (String) -> ()
    
    // MARK: - Initializers
    
    init(
        relationsService: RelationsServiceProtocol,
        detailsService: DetailsServiceProtocol,
        sections: [RelationsSection] = [],
        onValueEditingTap: @escaping (String) -> ()
    ) {
        self.relationsService = relationsService
        self.detailsService = detailsService
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
            case .checkbox(let bool) = relation
        else {
            onValueEditingTap(id)
            return
        }
        
        detailsService.updateDetails([
            DetailsUpdate(key: bool.id, value: Google_Protobuf_Value(boolValue: !bool.value))
        ])
    }
    
}
