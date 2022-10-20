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
        relationsService.removeRelation(relationKey: relation.key)
    }
    
    func showAddNewRelationView() {
        router.showAddNewRelationView { relation, isNew in
            AnytypeAnalytics.instance().logAddRelation(format: relation.format, isNew: isNew, type: .menu)
        }
    }
    
}
