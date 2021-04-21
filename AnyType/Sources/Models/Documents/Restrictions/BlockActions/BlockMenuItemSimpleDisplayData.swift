

import Foundation

struct BlockMenuItemSimpleDisplayData {
    let imageName: String
    let title: String
    let subtitle: String?
    
    init(imageName: String, title: String, subtitle: String? = nil) {
        self.imageName = imageName
        self.title = title
        self.subtitle = subtitle
    }
}
