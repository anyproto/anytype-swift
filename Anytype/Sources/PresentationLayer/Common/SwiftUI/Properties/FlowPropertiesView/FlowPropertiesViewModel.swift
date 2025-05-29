import SwiftUI

class FlowPropertiesViewModel: ObservableObject {
    let icon: Icon?
    let showIcon: Bool
    let canEditIcon: Bool
    let title: String?
    let description: String?
    let properties: [Relation]
    
    init(
        icon: Icon? = nil,
        showIcon: Bool = true,
        canEditIcon: Bool,
        title: String?,
        description: String?,
        properties: [Relation]
    ) {
        self.icon = icon
        self.showIcon = showIcon
        self.canEditIcon = canEditIcon
        self.title = title
        self.description = description
        self.properties = properties
    }
}
