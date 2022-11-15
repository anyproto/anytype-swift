import Foundation
import BlocksModels
import SwiftProtobuf
import UIKit
import AnytypeCore
import Combine

final class RelationsListViewModel: ObservableObject {
        
    @Published private(set) var navigationBarButtonsDisabled: Bool = false
    @Published var sections = [RelationsSection]()
    
    // MARK: - Private variables
    
    private let sectionsBuilder = RelationsSectionBuilder()
    private let relationsService: RelationsServiceProtocol
    
    private let router: EditorRouterProtocol
    private var subscriptions = [AnyCancellable]()
    
    // MARK: - Initializers
    
    init(
        document: BaseDocumentProtocol,
        router: EditorRouterProtocol,
        relationsService: RelationsServiceProtocol
    ) {
        self.router = router
        self.relationsService = relationsService
        
        document.parsedRelationsPublisher
            .map { [sectionsBuilder] relations in sectionsBuilder.buildSections(from: relations) }
            .assign(to: &$sections)
        
        document.isLockedPublisher.assign(to: &$navigationBarButtonsDisabled)
    }
    
}

// MARK: - Internal functions

extension RelationsListViewModel {
    
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
