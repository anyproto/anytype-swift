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
    
    func changeRelationFeaturedState(relationId: String) {
        let relationsRowData: [Relation] = sections.flatMap { $0.relations }
        let relationRowData = relationsRowData.first { $0.id == relationId }
        
        guard let relationRowData = relationRowData else { return }
        
        if relationRowData.isFeatured {
            relationsService.removeFeaturedRelation(relationKey: relationRowData.id)
        } else {
            relationsService.addFeaturedRelation(relationKey: relationRowData.id)
        }
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    func handleTapOnRelation(relationId: String) {
        AnytypeAnalytics.instance().logChangeRelationValue(type: .menu)
        router.showRelationValueEditingView(key: relationId, source: .object)
    }
    
    func removeRelation(id: String) {
        relationsService.removeRelation(relationKey: id)
    }
    
    func showAddNewRelationView() {
        router.showAddNewRelationView { relationMetadata, isNew in
            AnytypeAnalytics.instance().logAddRelation(format: relationMetadata.format, isNew: isNew, type: .menu)
        }
    }
    
}
