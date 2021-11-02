import Foundation

struct SlashMenuItemDisplayData {
    let iconData: ObjectIconImage
    let title: String
    let subtitle: String?
    let expandedIcon: Bool
    
    init(iconData: ObjectIconImage, title: String, subtitle: String? = nil, expandedIcon: Bool = false) {
        self.iconData = iconData
        self.title = title
        self.subtitle = subtitle
        self.expandedIcon = expandedIcon
    }
}
