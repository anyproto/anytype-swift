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
    
    private let source: RelationSource
    let onValueEditingTap: (String) -> ()
    
    // MARK: - Initializers
    
    init(
        source: RelationSource,
        relationsService: RelationsServiceProtocol,
        sections: [RelationsSection] = [],
        onValueEditingTap: @escaping (String) -> ()
    ) {
        self.source = source
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
        relationsService.removeRelation(source: source, relationKey: id)
    }    
}
