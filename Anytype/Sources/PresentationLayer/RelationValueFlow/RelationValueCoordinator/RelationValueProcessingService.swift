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
fileprivate final class RelationValueProcessingService: RelationValueProcessingServiceProtocol {
    
    @Injected(\.relationsService)
    private var relationsService: RelationsServiceProtocol
    
    nonisolated init() {}
    
    func canOpenRelationInNewModule(_ relation: Relation) -> Bool {
        if case .date = relation, relation.isEditable {
            return true
        }
        
        if case .status = relation {
            return true
        }
        
        if case .tag = relation {
            return true
        }
        
        if case .object = relation {
            return true
        }
        
        if case .file = relation {
            return true
        }
        
        if FeatureFlags.newTextEditingRelationView, case .text = relation {
            return true
        }
        
        if FeatureFlags.newTextEditingRelationView, case .number = relation {
            return true
        }
        
        if FeatureFlags.newTextEditingRelationView, case .email = relation {
            return true
        }
        
        if FeatureFlags.newTextEditingRelationView, case .phone = relation {
            return true
        }
        
        if FeatureFlags.newTextEditingRelationView, case .url = relation {
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
        if case .date = relation, !relation.isEditable {
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

extension Container {
    var relationValueProcessingService: Factory<RelationValueProcessingServiceProtocol> {
        self { RelationValueProcessingService() }.shared
    }
}
