import SwiftUI

enum ObjectSetting: CaseIterable {
    case icon
    case cover
    case layout
    case relations
    case history
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
            return Loc.fields
        case .history:
            return Loc.history
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
        case .history:
            return Loc.ObjectSettings.History.description
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
        case .history:
            return .ObjectSettings.history
        }
    }
}
