import Foundation
import BlocksModels
import SwiftProtobuf
import UIKit
import AnytypeCore

final class RelationsListViewModel: ObservableObject {
        
    @Published private(set) var navigationBarButtonsDisabled: Bool = false
    @Published private(set) var sections: [RelationsSection]
    
    // MARK: - Private variables
    
    private var parsedRelations: ParsedRelations = .empty {
        didSet {
            sections = sectionsBuilder.buildSections(from: parsedRelations)
        }
    }
    
    private let sectionsBuilder = RelationsSectionBuilder()
    private let relationsService: RelationsServiceProtocol
    
    private let router: EditorRouterProtocol
        
    // MARK: - Initializers
    
    init(
        router: EditorRouterProtocol,
        relationsService: RelationsServiceProtocol,
        sections: [RelationsSection] = [],
        isObjectLocked: Bool
    ) {
        self.router = router
        self.relationsService = relationsService
        self.sections = sections
        self.navigationBarButtonsDisabled = isObjectLocked
    }
    
}

// MARK: - Internal functions

extension RelationsListViewModel {
    
    func update(with parsedRelations: ParsedRelations, isObjectLocked: Bool) {
        self.parsedRelations = parsedRelations
        self.navigationBarButtonsDisabled = isObjectLocked
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
    
    func handleTapOnRelation(relationId: String) {
        router.showRelationValueEditingView(key: relationId, source: .object)
    }
    
    func removeRelation(id: String) {
        relationsService.removeRelation(relationKey: id)
    }
    
    func showAddNewRelationView() {
        router.showAddNewRelationView(onSelect: nil)
    }
    
}
