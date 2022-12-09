import BlocksModels

extension Relation {
    var hasSelectedObjectsRelationType: Bool {
        relationSelectedObjects.isNotEmpty
    }
    
    var relationSelectedObjects: [Relation.Object.Option] {
        if case let .object(object) = self {
            return object.selectedObjects.filter { $0.type == Constants.relationType }
        } else {
            return []
        }
    }
    
    var setOfPrefix: String? {
        guard key == BundledRelationKey.setOf.rawValue else {
            return nil
        }
        if relationSelectedObjects.isNotEmpty {
            return relationSelectedObjects.count == 1 ?
            Loc.Set.FeaturedRelations.relation: Loc.Set.FeaturedRelations.relationsList
        } else {
            return Loc.Set.FeaturedRelations.type
        }
    }
    
    var showIcon: Bool {
        key != BundledRelationKey.setOf.rawValue
    }
}

private enum Constants {
    static let relationType = "Relation"
}
