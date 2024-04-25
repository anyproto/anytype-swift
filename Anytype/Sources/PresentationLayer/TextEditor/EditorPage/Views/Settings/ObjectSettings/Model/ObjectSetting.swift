import SwiftUI

enum ObjectSetting: CaseIterable {
    case icon
    case cover
    case layout
    case relations
}

extension ObjectSetting {
    
    var title: String {
        switch self {
        case .icon:
            return Loc.icon
        case .cover:
            return Loc.cover
        case .layout:
            return Loc.layout
        case .relations:
            return Loc.relations
        }
    }
    
    var description: String {
        switch self {
        case .icon:
            return Loc.emojiOrImageForObject
        case .cover:
            return Loc.backgroundPicture
        case .layout:
            return Loc.arrangementOfObjectsOnACanvas
        case .relations:
            return Loc.listOfRelatedObjects
        }
    }
    
    var imageAsset: ImageAsset {
        switch self {
        case .icon:
            return .ObjectSettings.icon
        case .cover:
            return .ObjectSettings.cover
        case .layout:
            return .ObjectSettings.layout
        case .relations:
            return .ObjectSettings.relations
        }
    }
}
