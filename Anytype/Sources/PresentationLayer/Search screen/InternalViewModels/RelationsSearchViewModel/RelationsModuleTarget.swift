import Services


enum RelationsModuleTypeData {
    case recommendedFeaturedRelations(ObjectType)
    case recommendedRelations(ObjectType)
    
    var isFeatured: Bool {
        if case .recommendedFeaturedRelations = self {
            return true
        }
        return false
    }
}

enum RelationsModuleTarget {
    case type(RelationsModuleTypeData)
    case dataview(activeViewId: String, typeDetails: ObjectDetails?)
    case object(objectId: String)
}
