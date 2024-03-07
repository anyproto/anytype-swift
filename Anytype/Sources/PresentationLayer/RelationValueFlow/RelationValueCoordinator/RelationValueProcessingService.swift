import Foundation
import AnytypeCore
import Services

@MainActor
protocol RelationValueProcessingServiceProtocol {
    func canOpenRelationInNewModule(_ relation: Relation) -> Bool
    func relationProcessedSeparately(
        relation: Relation,
        objectId: String,
        analyticsType: AnalyticsEventsRelationType,
        onToastShow: ((String) -> Void)
    ) -> Bool
}

@MainActor
final class RelationValueProcessingService: RelationValueProcessingServiceProtocol {
    
    private let relationsService: RelationsServiceProtocol
    
    nonisolated init(relationsService: RelationsServiceProtocol) {
        self.relationsService = relationsService
    }
    
    func canOpenRelationInNewModule(_ relation: Relation) -> Bool {
        if FeatureFlags.newDateRelationCalendarView, case .date = relation, relation.isEditable {
            return true
        }
        
        if FeatureFlags.newSelectRelationView, case .status = relation {
            return true
        }
        
        if FeatureFlags.newMultiSelectRelationView, case .tag = relation {
            return true
        }
        
        if FeatureFlags.newObjectSelectRelationView, case .object = relation {
            return true
        }
        
        if FeatureFlags.newFileSelectRelationView, case .file = relation {
            return true
        }
        
        if FeatureFlags.newTextEditingRelationView, case .text = relation {
            return true
        }
        
        if FeatureFlags.newTextEditingRelationView, case .number = relation {
            return true
        }
        
        return false
    }
    
    func relationProcessedSeparately(
        relation: Relation,
        objectId: String,
        analyticsType: AnalyticsEventsRelationType,
        onToastShow: ((String) -> Void)
    ) -> Bool {
        if FeatureFlags.newDateRelationCalendarView, case .date = relation, !relation.isEditable {
            onToastShow(Loc.Relation.Date.Locked.Alert.title(relation.name))
            return true
        }
        
        guard relation.isEditable || relation.hasDetails else { return false }
        
        if case .checkbox(let checkbox) = relation {
            let newValue = !checkbox.value
            AnytypeAnalytics.instance().logChangeRelationValue(isEmpty: !newValue, type: analyticsType)
            Task {
                try await relationsService.updateRelation(objectId: objectId, relationKey: checkbox.key, value: newValue.protobufValue)
            }
            return true
        }
        
        return false
    }
}

struct RelationValueData: Identifiable {
    let id = UUID()
    let relation: Relation
    let objectDetails: ObjectDetails
}
