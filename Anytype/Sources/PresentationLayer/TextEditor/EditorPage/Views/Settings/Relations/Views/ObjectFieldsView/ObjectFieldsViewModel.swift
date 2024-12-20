import Foundation
import Services
import SwiftProtobuf
import UIKit
import AnytypeCore
import Combine

@MainActor
final class ObjectFieldsViewModel: ObservableObject {
    @Published var sections = [RelationsSection]()
    
    var typeId: String? { document.details?.objectType.id }
    
    // MARK: - Private variables
    
    private let document: any BaseDocumentProtocol
    private let sectionsBuilder = RelationsSectionBuilder()
    
    @Injected(\.relationsService)
    private var relationsService: any RelationsServiceProtocol
    @Injected(\.relationDetailsStorage)
    private var relationDetailsStorage: any RelationDetailsStorageProtocol
    @Injected(\.documentsProvider)
    private var documentsProvider: any DocumentsProviderProtocol
    
    private weak var output: (any RelationsListModuleOutput)?
    
    // MARK: - Initializers
    
    init(
        document: some BaseDocumentProtocol,
        output: (any RelationsListModuleOutput)?
    ) {
        self.document = document
        self.output = output
    }
    
    func setupSubscriptions() async {
        for await relations in document.parsedRelationsPublisher.values {
            sections = sectionsBuilder.buildObjectSections(from: relations)
        }
    }
    
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
            let relationDetails = try relationDetailsStorage.relationsDetails(key: relation.key, spaceId: document.spaceId)
            if relation.isFeatured {
                try await relationsService.removeFeaturedRelation(objectId: document.objectId, relationKey: relation.key)
                AnytypeAnalytics.instance().logUnfeatureRelation(spaceId: document.spaceId, format: relationDetails.format, key: relationDetails.analyticsKey)
            } else {
                try await relationsService.addFeaturedRelation(objectId: document.objectId, relationKey: relation.key)
                AnytypeAnalytics.instance().logFeatureRelation(spaceId: document.spaceId, format: relationDetails.format, key: relationDetails.analyticsKey)
            }
        }
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    func handleTapOnRelation(relation: Relation) {
        output?.editRelationValueAction(document: document, relationKey: relation.key)
    }
    
    func removeRelation(relation: Relation) {
        Task {
            try await relationsService.removeRelation(objectId: document.objectId, relationKey: relation.key)
            let relationDetails = try relationDetailsStorage.relationsDetails(key: relation.key, spaceId: document.spaceId)
            AnytypeAnalytics.instance().logDeleteRelation(spaceId: document.spaceId, format: relationDetails.format, key: relationDetails.analyticsKey)
        }
    }
    
    func onEditTap() {
        guard let typeId else { return }
        output?.showTypeRelationsView(typeId: typeId)
    }
}
