import Foundation
import AnytypeCore
import Services

@MainActor
protocol PropertyValueProcessingServiceProtocol {
    func handlePropertyValue(
        relation: Relation,
        objectDetails: ObjectDetails,
        analyticsType: AnalyticsEventsRelationType
    ) -> PropertyValueData?
}

@MainActor
fileprivate final class PropertyValueProcessingService: PropertyValueProcessingServiceProtocol {
    
    @Injected(\.relationsService)
    private var relationsService: any RelationsServiceProtocol
    @Injected(\.relationDetailsStorage)
    private var relationDetailsStorage: any RelationDetailsStorageProtocol
    
    nonisolated init() {}
    
    func handlePropertyValue(
        relation: Relation,
        objectDetails: ObjectDetails,
        analyticsType: AnalyticsEventsRelationType
    ) -> PropertyValueData? {
        switch relation {
        case .status, .tag, .object, .date, .file, .text, .number, .url, .email, .phone:
            return PropertyValueData(
                relation: relation,
                objectDetails: objectDetails, 
                analyticsType: analyticsType
            )
        case .checkbox(let checkbox):
            guard relation.isEditable else { return nil }
            Task {
                let newValue = !checkbox.value
                try await relationsService.updateRelation(objectId: objectDetails.id, relationKey: checkbox.key, value: newValue.protobufValue)
                let relationDetails = try relationDetailsStorage.relationsDetails(key: relation.key, spaceId: objectDetails.spaceId)
                AnytypeAnalytics.instance().logChangeOrDeleteRelationValue(
                    isEmpty: !newValue,
                    format: relationDetails.format,
                    type: analyticsType,
                    key: relationDetails.analyticsKey,
                    spaceId: objectDetails.spaceId
                )
            }
        case .unknown:
            return nil
        }
        
        return nil
    }
}

struct PropertyValueData: Identifiable {
    let id = UUID()
    let relation: Relation
    let objectDetails: ObjectDetails
    let analyticsType: AnalyticsEventsRelationType
}

extension Container {
    var propertyValueProcessingService: Factory<any PropertyValueProcessingServiceProtocol> {
        self { PropertyValueProcessingService() }.shared
    }
}
