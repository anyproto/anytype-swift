import Foundation
import BlocksModels
import SwiftProtobuf
import UIKit
import AnytypeCore

final class RelationsListViewModel: ObservableObject {
        
    @Published private(set) var navigationBarButtonsDisabled: Bool = false
    
    var sections: [RelationsSection] {
        sectionsBuilder.buildSections(from: parsedRelations)
    }
    
    // MARK: - Private variables
    
    @Published private var parsedRelations: ParsedRelations = .empty
    
    private let sectionsBuilder = RelationsSectionBuilder()
    private let relationsService: RelationsServiceProtocol
    
    private let router: EditorRouterProtocol
        
    // MARK: - Initializers
    
    init(
        router: EditorRouterProtocol,
        relationsService: RelationsServiceProtocol,
        isObjectLocked: Bool
    ) {
        self.router = router
        self.relationsService = relationsService
        self.navigationBarButtonsDisabled = isObjectLocked
    }
    
}

// MARK: - Internal functions

extension RelationsListViewModel {
    
    func update(with parsedRelations: ParsedRelations, isObjectLocked: Bool) {
        self.parsedRelations = parsedRelations
        self.navigationBarButtonsDisabled = isObjectLocked
    }
    
    func changeRelationFeaturedState(relation: Relation) {
//        let relationsRowData: [Relation] = sections.flatMap { $0.relations }
//        let relationRowData = relationsRowData.first { $0.key == relationKey }
//
//        guard let relationRowData = relationRowData else { return }
        
        if relation.isFeatured {
            relationsService.removeFeaturedRelation(relationKey: relation.key)
        } else {
            relationsService.addFeaturedRelation(relationKey: relation.key)
        }
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    func handleTapOnRelation(relation: Relation) {
        AnytypeAnalytics.instance().logChangeRelationValue(type: .menu)
        router.showRelationValueEditingView(key: relation.key, source: .object)
    }
    
    func removeRelation(relation: Relation) {
        relationsService.removeRelation(relationId: relation.id)
    }
    
    func showAddNewRelationView() {
        router.showAddNewRelationView { relationDetails, isNew in
            AnytypeAnalytics.instance().logAddRelation(format: relationDetails.format, isNew: isNew, type: .menu)
        }
    }
    
}
