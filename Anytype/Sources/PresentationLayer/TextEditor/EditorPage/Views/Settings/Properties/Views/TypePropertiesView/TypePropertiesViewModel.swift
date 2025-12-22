import Foundation
import Services
import SwiftProtobuf
import AnytypeCore
import SwiftUI


@MainActor
@Observable
final class TypePropertiesViewModel {

    var canEditPropertiesList = false
    var showConflictingInfo = false
    var relationRows = [TypePropertiesRow]()
    var relationsSearchData: PropertiesSearchData?
    var propertyData: PropertyInfoData?
    var conflictRelations = [PropertyDetails]()

    // MARK: - Private variables

    let document: any BaseDocumentProtocol
    @ObservationIgnored
    private let fieldsDataBuilder = TypePropertiesRowBuilder()
    @ObservationIgnored
    private let moveHandler = TypePropertiesMoveHandler()

    @ObservationIgnored
    private var parsedProperties = ParsedProperties.empty

    @ObservationIgnored @Injected(\.propertiesService)
    private var propertiesService: any PropertiesServiceProtocol
    @ObservationIgnored @Injected(\.propertyDetailsStorage)
    private var propertyDetailsStorage: any PropertyDetailsStorageProtocol
    @ObservationIgnored @Injected(\.singlePropertyBuilder)
    private var relationsBuilder: any SinglePropertyBuilderProtocol
    
    
    // MARK: - Initializers
    
    convenience init(data: EditorTypeObject) {
        let document = Container.shared.openedDocumentProvider().document(objectId: data.objectId, spaceId: data.spaceId)
        self.init(document: document)
    }
    
    init(document: some BaseDocumentProtocol) {
        self.document = document
    }
    
    func setupSubscriptions() async {
        async let relationsSubscription: () = setupRelationsSubscription()
        async let permissionSubscription: () = setupPermissionSubscription()
        async let detailsSubscription: () = setupDetailsSubscription()
        
        (_, _, _) = await (relationsSubscription, permissionSubscription, detailsSubscription)
    }
    
    private func setupRelationsSubscription() async {
        for await properties in document.parsedPropertiesPublisherForType.values {
            parsedProperties = properties
            let newRows = fieldsDataBuilder.build(
                relations: properties.sidebarProperties,
                featured: properties.featuredProperties,
                hidden: properties.hiddenProperties
            )
            
            // do not animate on 1st appearance
            withAnimation(relationRows.isNotEmpty ? .default : nil) {
                relationRows = newRows
            }
            
        }
    }
    
    private func setupPermissionSubscription() async {
        for await permissions in document.permissionsPublisher.values {
            canEditPropertiesList = permissions.canEditPropertiesList
        }
    }
    
    func setupDetailsSubscription() async {
        for await details in document.detailsPublisher.values {
            try? await updateConflictRelations(details: details)
        }
    }
    
    func onRelationTap(_ data: TypePropertiesRelationRow) {
        guard let details = document.details else { return }
        guard let format = data.relation.format else { return }
        
        let type = ObjectType(details: details)
        
        let typeData: PropertiesModuleTypeData = data.relation.isFeatured ? .recommendedFeaturedRelations(type) : .recommendedRelations(type)
        
        propertyData = PropertyInfoData(
            name: data.relation.name,
            objectId: document.objectId,
            spaceId: document.spaceId,
            target: .type(typeData),
            mode: .edit(relationId: data.relation.id, format: format, limitedObjectTypes: data.relation.limitedObjectTypes),
            isReadOnly: !data.relation.isEditable
        )
    }
    
    func onAddRelationTap(section: TypePropertiesSectionRow) {
        guard let details = document.details else { return }
        let type = ObjectType(details: details)
        let typeData: PropertiesModuleTypeData = section.isFeatured ? .recommendedFeaturedRelations(type) : .recommendedRelations(type)
        
        relationsSearchData = PropertiesSearchData(
            objectId: document.objectId,
            spaceId: document.spaceId,
            excludedRelationsIds: relationRows.compactMap(\.relationId),
            target: .type(typeData),
            onRelationSelect: { details, isNew in
                AnytypeAnalytics.instance().logAddExistingOrCreateRelation(
                    format: details.format, isNew: isNew, type: .type, key: details.analyticsKey
                )
            }
        )
    }
    
    func onConflictingInfoTap() {
        AnytypeAnalytics.instance().logConflictFieldHelp()
        showConflictingInfo.toggle()
    }
    
    func onRelationRemove(_ row: TypePropertiesRelationRow) {
        guard let details = document.details else { return }
        
        Task {
            try await propertiesService.removeTypeProperty(details: details, propertyId: row.relation.id)
            
            guard let format = row.relation.format?.format else {
                anytypeAssertionFailure("Empty relation format for onRelationRemove")
                return
            }
            AnytypeAnalytics.instance().logDeleteRelation(format: format, route: .type)
        }
    }
    
    func onAddConflictRelation(_ relation: PropertyDetails) {
        guard let details = document.details else { return }
        AnytypeAnalytics.instance().logAddConflictRelation()
        
        Task {
            try await propertiesService.addTypeRecommendedProperty(details: details, property: relation)    
            if let details = document.details { try await updateConflictRelations(details: details) }
        }
    }
    
    private func updateConflictRelations(details: ObjectDetails) async throws {
        let releationKeys = try await propertiesService.getConflictPropertiesForType(typeId: document.objectId, spaceId: document.spaceId)
        conflictRelations = propertyDetailsStorage
            .relationsDetails(ids: releationKeys, spaceId: document.spaceId)
            .filter { !$0.isHidden && !$0.isDeleted }
        
        let newRows = fieldsDataBuilder.build(
            relations: parsedProperties.sidebarProperties,
            featured: parsedProperties.featuredProperties,
            hidden: parsedProperties.hiddenProperties
        )
        
        // do not animate on 1st appearance
        withAnimation(relationRows.isNotEmpty ? .default : nil) {
            relationRows = newRows
        }
    }
}
