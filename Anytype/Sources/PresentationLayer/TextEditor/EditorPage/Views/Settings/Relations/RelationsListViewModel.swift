import Foundation
import Services
import SwiftProtobuf
import UIKit
import AnytypeCore
import Combine

@MainActor
final class RelationsListViewModel: ObservableObject {
        
    @Published private(set) var navigationBarButtonsDisabled: Bool = false
    @Published var sections = [RelationsSection]()
    
    // MARK: - Private variables
    
    private let document: BaseDocumentProtocol
    private let sectionsBuilder = RelationsSectionBuilder()
    private let relationsService: RelationsServiceProtocol
    
    private weak var output: RelationsListModuleOutput?
    
    private var subscriptions: [AnyCancellable] = []
    
    // MARK: - Initializers
    
    init(
        document: BaseDocumentProtocol,
        relationsService: RelationsServiceProtocol,
        output: RelationsListModuleOutput
    ) {
        self.document = document
        self.relationsService = relationsService
        self.output = output
        
        document.parsedRelationsPublisher
            .map { [sectionsBuilder] relations in
                sectionsBuilder.buildSections(
                    from: relations,
                    objectTypeName: document.details?.objectType.name ?? ""
                )
            }
            .receiveOnMain()
            .assign(to: &$sections)
        
        document.syncPublisher
            .receiveOnMain()
            .sink { [weak self] in
                guard let self else { return }
                navigationBarButtonsDisabled = !document.permissions.canEditRelationsList
            }
            .store(in: &subscriptions)
    }
    
}

// MARK: - Internal functions

extension RelationsListViewModel {
    
    func changeRelationFeaturedState(relation: Relation, addedToObject: Bool) {
        if !addedToObject {
            Task { @MainActor in
                try await relationsService.addRelations(objectId: document.objectId, relationKeys: [relation.key])
                changeRelationFeaturedState(relation: relation)
            }
        } else {
            changeRelationFeaturedState(relation: relation)
        }
    }
    
    private func changeRelationFeaturedState(relation: Relation) {
        Task {
            if relation.isFeatured {
                AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.removeFeatureRelation)
                try await relationsService.removeFeaturedRelation(objectId: document.objectId, relationKey: relation.key)
            } else {
                AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.addFeatureRelation)
                try await relationsService.addFeaturedRelation(objectId: document.objectId, relationKey: relation.key)
            }
        }
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    func handleTapOnRelation(relation: Relation) {
        output?.editRelationValueAction(document: document, relationKey: relation.key)
    }
    
    func removeRelation(relation: Relation) {
        Task {
            AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.deleteRelation)
            try await relationsService.removeRelation(objectId: document.objectId, relationKey: relation.key)
        }
    }
    
    func showAddNewRelationView() {
        output?.addNewRelationAction(document: document)
    }
    
}
