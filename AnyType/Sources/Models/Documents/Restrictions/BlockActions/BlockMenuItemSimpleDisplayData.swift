

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
    
    func contains(string: String) -> Bool {
        if title.contains(string) {
            return true
        }
        if let subtitle = subtitle, subtitle.contains(string) {
            return true
        }
        return false
    }
}
