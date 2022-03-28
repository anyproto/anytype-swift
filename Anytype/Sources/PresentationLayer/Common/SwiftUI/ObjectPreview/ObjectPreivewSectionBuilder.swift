import BlocksModels
import SwiftUI

final class ObjectPreivewSectionBuilder {

    func build(featuredRelationsByIds: [String: Relation], fields: MiddleBlockFields) -> ObjectPreviewViewSection {
        var featuredRelationSection: [ObjectPreviewViewFeaturedSectionItem] = []
        let objectPreviewFields = ObjectPreviewFieldsConverter.convertToModel(fields: fields)

        let layout = ObjectPreviewViewMainSectionItem(id: IDs.layout, name: "Preview layout".localized, value: objectPreviewFields.layout.name)
        let icon = ObjectPreviewViewMainSectionItem(id: IDs.icon, name: "Icon".localized, value: objectPreviewFields.icon.name)
        let mainSection = [layout, icon]

        featuredRelationsByIds.forEach { (key: String, relation: Relation) in
            let icon = Image.Relations.relationIcon(format: relation.format)

            let isEnabled = objectPreviewFields.featuredRelationsIds.contains(key)
            let featuredRelation = ObjectPreviewViewFeaturedSectionItem(
                id: relation.id,
                icon: icon,
                name: relation.name,
                isEnabled: isEnabled
            )
            featuredRelationSection.append(featuredRelation)
        }

        return .init(main: mainSection, featuredRelation: featuredRelationSection)
    }
}

extension ObjectPreivewSectionBuilder {
    enum IDs {
        static let layout = "layout"
        static let icon = "icon"
    }
}
