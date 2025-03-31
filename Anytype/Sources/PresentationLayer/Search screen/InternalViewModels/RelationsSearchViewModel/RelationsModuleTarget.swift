import Services


enum RelationsModuleTypeData {
    case recommendedFeaturedRelations(ObjectDetails)
    case recommendedRelations(ObjectDetails)
    
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
}
