import Services
@testable import Anytype


extension Property {
    static func mock(id: String) -> Property {
        .checkbox(Property.Checkbox(id: id, key: id, name: "MockRelation" + id, isFeatured: false, isEditable: false, canBeRemovedFromObject: false, isDeleted: false, value: false))
    }
}

extension ObjectDetails {
    static func mock(
        objectId: String = "",
        recommendedFeaturedRelations: [String] = [],
        recommendedRelations: [String] = []
    ) -> ObjectDetails {
        ObjectDetails.init(
            id: objectId,
            values: [
                BundledPropertyKey.recommendedRelations.rawValue: recommendedRelations.protobufValue,
                BundledPropertyKey.recommendedFeaturedRelations.rawValue: recommendedFeaturedRelations.protobufValue
            ]
        )
    }
}
