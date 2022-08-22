import SwiftUI

class FlowRelationsViewModel: ObservableObject {
    let icon: ObjectIconImage?
    let showIcon: Bool
    let title: String?
    let description: String?
    let relations: [Relation]
    let style: FlowRelationsStyle
    let onRelationTap: (Relation) -> Void
    let onIconTap: () -> Void
    
    init(
        icon: ObjectIconImage? = nil,
        showIcon: Bool = true,
        title: String?,
        description: String?,
        relations: [Relation],
        style: FlowRelationsStyle,
        onIconTap: @escaping () -> Void = {},
        onRelationTap: @escaping (Relation) -> Void
    ) {
        self.icon = icon
        self.showIcon = showIcon
        self.title = title
        self.description = description
        self.relations = relations
        self.style = style
        self.onIconTap = onIconTap
        self.onRelationTap = onRelationTap
    }
}
