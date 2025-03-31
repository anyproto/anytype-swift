import Foundation
import Services
import SwiftProtobuf
import UIKit
import AnytypeCore
import Combine

@MainActor
final class ObjectFieldsViewModel: ObservableObject {
    @Published var sections = [RelationsSection]()
    @Published var showConflictingInfo = false
    
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
            sections = sectionsBuilder.buildObjectSections(parsedRelations: relations)
        }
    }
    
    func handleTapOnRelation(_ relation: Relation) {
        output?.editRelationValueAction(document: document, relationKey: relation.key)
    }
    
    func removeRelation(_ relation: Relation) {
        Task {
            try await relationsService.removeRelation(objectId: document.objectId, relationKey: relation.key)
            let relationDetails = try relationDetailsStorage.relationsDetails(key: relation.key, spaceId: document.spaceId)
            AnytypeAnalytics.instance().logDeleteRelation(spaceId: document.spaceId, format: relationDetails.format, key: relationDetails.analyticsKey, route: .object)
        }
    }
    
    func onEditTap() {
        guard let typeId else { return }
        output?.showTypeRelationsView(typeId: typeId)
    }
    
    func addRelationToType(_ relation: Relation) {
        AnytypeAnalytics.instance().logAddConflictRelation()
        guard let details = document.details else { return }
        
        var newRecommendedRelations = document.parsedRelations.sidebarRelations
        newRecommendedRelations.append(relation)
        
        let relationsDetails = relationDetailsStorage.relationsDetails(ids: newRecommendedRelations.map(\.id), spaceId: document.spaceId)
        
        Task {
            try await relationsService
                .updateTypeRelations(
                    typeId: details.type,
                    recommendedRelations: relationsDetails,
                    recommendedFeaturedRelations: details.recommendedFeaturedRelationsDetails,
                    recommendedHiddenRelations: details.recommendedHiddenRelationsDetails
                )
        }
    }
    
    func onConflictingInfoTap() {
        AnytypeAnalytics.instance().logConflictFieldHelp()
        showConflictingInfo.toggle()
    }
}
