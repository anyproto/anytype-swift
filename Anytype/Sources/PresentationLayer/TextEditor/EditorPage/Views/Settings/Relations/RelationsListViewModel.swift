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
    
    func changeRelationFeaturedState(relationValue: RelationValue) {
        if relationValue.isFeatured {
            relationsService.removeFeaturedRelation(relationKey: relationValue.key)
        } else {
            relationsService.addFeaturedRelation(relationKey: relationValue.key)
        }
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    func handleTapOnRelation(relationValue: RelationValue) {
        AnytypeAnalytics.instance().logChangeRelationValue(type: .menu)
        router.showRelationValueEditingView(key: relationValue.key, source: .object)
    }
    
    func removeRelation(relationValue: RelationValue) {
        relationsService.removeRelation(relationId: relationValue.id)
    }
    
    func showAddNewRelationView() {
        router.showAddNewRelationView { relation, isNew in
            AnytypeAnalytics.instance().logAddRelation(format: relation.format, isNew: isNew, type: .menu)
        }
    }
    
}
