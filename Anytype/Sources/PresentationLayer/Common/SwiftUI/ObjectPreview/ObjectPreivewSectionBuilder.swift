import BlocksModels
import SwiftUI

final class ObjectPreivewSectionBuilder {

    func build(appearance: BlockLink.Appearance) -> ObjectPreviewViewSection {
        var featuredRelationSection: [ObjectPreviewViewSection.FeaturedSectionItem] = []

        let layout = ObjectPreviewViewSection.MainSectionItem(
            id: IDs.layout,
            name: "Preview layout".localized,
            value: .layout(.init(appearance.cardStyle))
        )

        let hasIcon = appearance.relations.contains(.icon)
        let icon = ObjectPreviewViewSection.MainSectionItem(
            id: IDs.icon,
            name: "Icon".localized,
            value: .icon(hasIcon ? .medium : .none)
        )

        let mainSection = [layout, icon]

        let withName = ObjectPreviewViewSection.FeaturedSectionItem(
            id: .name,
            iconName: RelationMetadata.Format.shortText.iconName,
            name: "Name".localized,
            isEnabled: appearance.relations.contains(.name)
        )
        featuredRelationSection.append(withName)

        let withDescription = ObjectPreviewViewSection.FeaturedSectionItem(
            id: .description,
            iconName: RelationMetadata.Format.longText.iconName,
            name: "Description".localized,
            isEnabled: appearance.description.hasDescription
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
