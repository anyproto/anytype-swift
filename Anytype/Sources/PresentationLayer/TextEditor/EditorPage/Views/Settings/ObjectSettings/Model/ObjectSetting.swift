import SwiftUI

enum ObjectSetting: CaseIterable {
    case relations
    case icon
    case cover
    case history
}

extension ObjectSetting {
    
    var title: String {
        switch self {
        case .icon:
            return Loc.icon
        case .cover:
            return Loc.cover
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
        case .relations:
            return .ObjectSettings.relations
        case .history:
            return .ObjectSettings.history
        }
    }
}
