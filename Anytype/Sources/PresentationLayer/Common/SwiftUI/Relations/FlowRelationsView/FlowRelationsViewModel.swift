import SwiftUI

class FlowRelationsViewModel: ObservableObject {
    let icon: ObjectIconImage?
    let showIcon: Bool
    let title: String?
    let description: String?
    let relationValues: [RelationValue]
    let onRelationTap: (RelationValue) -> Void
    let onIconTap: () -> Void
    
    init(
        icon: ObjectIconImage? = nil,
        showIcon: Bool = true,
        title: String?,
        description: String?,
        relationValues: [RelationValue],
        onIconTap: @escaping () -> Void = {},
        onRelationTap: @escaping (RelationValue) -> Void
    ) {
        self.icon = icon
        self.showIcon = showIcon
        self.title = title
        self.description = description
        self.relationValues = relationValues
        self.onIconTap = onIconTap
        self.onRelationTap = onRelationTap
    }
}
