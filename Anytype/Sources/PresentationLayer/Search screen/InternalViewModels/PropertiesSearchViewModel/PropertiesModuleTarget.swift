import Services


enum PropertiesModuleTypeData {
    case recommendedFeaturedRelations(ObjectType)
    case recommendedRelations(ObjectType)
    
    var isFeatured: Bool {
        if case .recommendedFeaturedRelations = self {
            return true
        }
        return false
    }
}

enum PropertiesModuleTarget {
    case type(PropertiesModuleTypeData)
    case dataview(objectId: String, activeViewId: String, typeDetails: ObjectDetails?)
    case object(objectId: String)
    case library
}
