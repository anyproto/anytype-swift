import Foundation
import BlocksModels
import SwiftProtobuf
import UIKit
import AnytypeCore

final class RelationsListViewModel: ObservableObject {
        
    @Published private(set) var sections: [RelationsSection]
    
    let onValueEditingTap: (String) -> ()

    // MARK: - Private variables

    private let sectionsBuilder = RelationsSectionBuilder()
    private let relationsService: RelationsServiceProtocol 
    
    private var parsedRelations: ParsedRelations = .empty {
        didSet {
            sections = sectionsBuilder.buildSections(from: parsedRelations)
        }
    }
        
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
    
}

// MARK: - Internal functions

extension RelationsListViewModel {
    
    func update(with parsedRelations: ParsedRelations) {
        self.parsedRelations = parsedRelations
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
    
    var searchNewRelationViewModel: SearchNewRelationViewModel {
        SearchNewRelationViewModel(
            relationService: relationsService,
            objectRelations: parsedRelations,
            onSelect: { _ in }
        )
    }
    
}
