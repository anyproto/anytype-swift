import Foundation

struct SlashMenuItemDisplayData {
    let iconData: ObjectIconImage
    let title: String
    let subtitle: String?
    
    init(iconData: ObjectIconImage, title: String, subtitle: String? = nil) {
        self.iconData = iconData
        self.title = title
        self.subtitle = subtitle
    }
}
