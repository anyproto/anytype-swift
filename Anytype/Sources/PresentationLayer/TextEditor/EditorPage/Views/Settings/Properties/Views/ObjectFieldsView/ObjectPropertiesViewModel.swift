import Foundation
import Services
import SwiftProtobuf
import UIKit
import AnytypeCore
import Combine
import SwiftUI

@MainActor
final class ObjectPropertiesViewModel: ObservableObject {
    @Published var sections = [PropertiesSection]()
    @Published var showConflictingInfo = false
    @Published var expandedSections = Set<String>()
    
    var typeId: String? { document.details?.objectType.id }
    
    var shouldShowEmptyState: Bool {
        guard let firstSection = sections.first else { return true }
        return firstSection.id != PropertiesSection.Constants.featuredPropertiesSectionId
    }
    
    // MARK: - Private variables
    
    private let document: any BaseDocumentProtocol
    private let sectionsBuilder = PropertiesSectionBuilder()
    
    @Injected(\.propertiesService)
    private var propertiesService: any PropertiesServiceProtocol
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
        for await properties in document.parsedPropertiesPublisher.values {
            sections = sectionsBuilder.buildObjectSections(parsedProperties: properties)
        }
    }
    
    func handleTapOnRelation(_ relation: Relation) {
        output?.editRelationValueAction(document: document, relationKey: relation.key)
    }
    
    func removeRelation(_ relation: Relation) {
        Task {
            try await propertiesService.removeProperty(objectId: document.objectId, propertyKey: relation.key)
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
            try await propertiesService.addTypeRecommendedProperty(type: details.objectType, property: relationsDetail)
        }
    }
    
    func onConflictingInfoTap() {
        AnytypeAnalytics.instance().logConflictFieldHelp()
        showConflictingInfo.toggle()
    }
    
    func toggleSectionExpansion(_ sectionId: String) {
        withAnimation(.fastSpring) {
            if expandedSections.contains(sectionId) {
                expandedSections.remove(sectionId)
            } else {
                expandedSections.insert(sectionId)
            }
        }
    }
    
    func isSectionExpanded(_ sectionId: String) -> Bool {
        expandedSections.contains(sectionId)
    }
}
