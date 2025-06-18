import Services

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
        guard key == BundledPropertyKey.setOf.rawValue else {
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
        key != BundledPropertyKey.setOf.rawValue
    }
    
    var links: Object.Links? {
        if case let .object(object) = self {
            return object.links
        } else {
            return nil
        }
    }
}

private enum Constants {
    static let relationType = "Relation"
}
