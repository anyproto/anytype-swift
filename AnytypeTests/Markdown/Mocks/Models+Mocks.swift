import Services
@testable import Anytype


extension Relation {
    static func mock(id: String) -> Relation {
        .checkbox(Checkbox(id: id, key: id, name: "MockRelation" + id, isFeatured: false, isEditable: false, canBeRemovedFromObject: false, isDeleted: false, value: false))
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
                BundledRelationKey.recommendedRelations.rawValue: recommendedRelations.protobufValue,
                BundledRelationKey.recommendedFeaturedRelations.rawValue: recommendedFeaturedRelations.protobufValue
            ]
        )
    }
}
