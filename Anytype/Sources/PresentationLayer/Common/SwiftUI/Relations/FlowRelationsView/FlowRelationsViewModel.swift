import SwiftUI

class FlowRelationsViewModel: ObservableObject {
    let icon: Icon?
    let showIcon: Bool
    let title: String?
    let description: String?
    let relations: [Relation]
    let onRelationTap: (Relation) -> Void
    let onIconTap: () -> Void
    
    init(
        icon: Icon? = nil,
        showIcon: Bool = true,
        title: String?,
        description: String?,
        relations: [Relation],
        onIconTap: @escaping () -> Void = {},
        onRelationTap: @escaping (Relation) -> Void
    ) {
        self.icon = icon
        self.showIcon = showIcon
        self.title = title
        self.description = description
        self.relations = relations
        self.onIconTap = onIconTap
        self.onRelationTap = onRelationTap
    }
}
