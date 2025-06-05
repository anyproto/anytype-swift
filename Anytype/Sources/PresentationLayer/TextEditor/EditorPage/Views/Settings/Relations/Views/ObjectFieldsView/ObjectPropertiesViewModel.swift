import Foundation
import Services
import SwiftProtobuf
import UIKit
import AnytypeCore
import Combine

@MainActor
final class ObjectPropertiesViewModel: ObservableObject {
    @Published var sections = [PropertiesSection]()
    @Published var showConflictingInfo = false
    
    var typeId: String? { document.details?.objectType.id }
    
    // MARK: - Private variables
    
    private let document: any BaseDocumentProtocol
    private let sectionsBuilder = PropertiesSectionBuilder()
    
    @Injected(\.relationsService)
    private var relationsService: any RelationsServiceProtocol
    @Injected(\.propertyDetailsStorage)
    private var propertyDetailsStorage: any PropertyDetailsStorageProtocol
    @Injected(\.documentsProvider)
    private var documentsProvider: any DocumentsProviderProtocol
    
    private weak var output: (any PropertiesListModuleOutput)?
    
    // MARK: - Initializers
    
    init(
        document: some BaseDocumentProtocol,
        output: (any PropertiesListModuleOutput)?
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
            let relationDetails = try propertyDetailsStorage.relationsDetails(key: relation.key, spaceId: document.spaceId)
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
        
        Task {
            let relationsDetail = try propertyDetailsStorage.relationsDetails(key: relation.key, spaceId: details.spaceId)
            try await relationsService.addTypeRecommendedRelation(type: details.objectType, relation: relationsDetail)
        }
    }
    
    func onConflictingInfoTap() {
        AnytypeAnalytics.instance().logConflictFieldHelp()
        showConflictingInfo.toggle()
    }
}
