

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
        let lowercasedString = string.lowercased()
        if title.lowercased().contains(lowercasedString) {
            return true
        }
        if let subtitle = subtitle, subtitle.lowercased().contains(lowercasedString) {
            return true
        }
        return false
    }
}
