import SwiftUI

enum ObjectSetting: CaseIterable {
    case icon
    case cover
    case layout
    case relations

    static var lockedEditingCases: [ObjectSetting] { [.relations] }
}

extension ObjectSetting {
    
    var title: String {
        switch self {
        case .icon:
            return "Icon".localized
        case .cover:
            return "Cover".localized
        case .layout:
            return "Layout".localized
        case .relations:
            return "Relations".localized
        }
    }
    
    var description: String {
        switch self {
        case .icon:
            return "Emoji or image for object".localized
        case .cover:
            return "Background picture".localized
        case .layout:
            return "Arrangement of objects on a canvas".localized
        case .relations:
            return "List of related objects".localized
        }
    }
    
    var image: Image {
        switch self {
        case .icon:
            return Image.ObjectSettings.icon
        case .cover:
            return Image.ObjectSettings.cover
        case .layout:
            return Image.ObjectSettings.layout
        case .relations:
            return Image.ObjectSettings.relations
        }
    }
}
