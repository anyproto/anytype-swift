import BlocksModels
import SwiftUI

final class ObjectPreivewSectionBuilder {

    func build(featuredRelationsByIds: [String: Relation], objectPreviewFields: ObjectPreviewFields) -> ObjectPreviewViewSection {
        var featuredRelationSection: [ObjectPreviewViewFeaturedSectionItem] = []

        let layout = ObjectPreviewViewMainSectionItem(
            id: IDs.layout,
            name: "Preview layout".localized,
            value: .layout(objectPreviewFields.layout)
        )
        let icon = ObjectPreviewViewMainSectionItem(
            id: IDs.icon,
            name: "Icon".localized,
            value: .icon(objectPreviewFields.icon))
        let mainSection = [layout, icon]

        let withNameRelation = ObjectPreviewViewFeaturedSectionItem(
            id: BundledRelationKey.name.rawValue,
            iconName: RelationMetadata.Format.shortText.iconName,
            name: "Name".localized,
            isEnabled: objectPreviewFields.withName
        )
        featuredRelationSection.append(withNameRelation)

        let isEnabledDescription = objectPreviewFields.featuredRelationsIds.contains(BundledRelationKey.description.rawValue)
        let withDescription = ObjectPreviewViewFeaturedSectionItem(
            id: BundledRelationKey.description.rawValue,
            iconName: RelationMetadata.Format.longText.iconName,
            name: "Description".localized,
            isEnabled: isEnabledDescription
        )
        featuredRelationSection.append(withDescription)

        return .init(main: mainSection, featuredRelation: featuredRelationSection)
    }
}

extension ObjectPreivewSectionBuilder {
    enum IDs {
        static let layout = "layout"
        static let icon = "icon"
    }
}
