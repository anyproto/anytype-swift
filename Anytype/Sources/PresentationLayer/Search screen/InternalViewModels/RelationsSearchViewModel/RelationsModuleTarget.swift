enum RelationsModuleTypeData {
    case recommendedFeaturedRelations([String])
    case recommendedRelations([String])
    
    var isFeatured: Bool {
        if case .recommendedFeaturedRelations = self {
            return true
        }
        return false
    }
}

enum RelationsModuleTarget {
    case type(RelationsModuleTypeData)
    case dataview(activeViewId: String)
}
