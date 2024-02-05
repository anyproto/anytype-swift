import Foundation
import SwiftUI

enum AppIcon {
    case oldSchool
    case smile
    case standart
    case classic
    
    var previewAsset: ImageAsset {
        switch self {
        case .standart: return .AppIconsPreview.appIcon
        case .oldSchool: return .AppIconsPreview.appIconOldSchool
        case .classic: return .AppIconsPreview.appIconClassic
        case .smile: return .AppIconsPreview.appIconSmile
        }
    }
    
    var iconName: String? {
        switch self {
        case .standart: return nil
        case .oldSchool: return "AppIconOldSchool"
        case .classic: return "AppIconClassic"
        case .smile: return "AppIconSmile"
        }
    }
    
    static var availableCases: [AppIcon] {
        #if DEBUG
        [.smile, .standart, .classic]
        #else
        [.oldSchool, .standart, .classic]
        #endif
    }
}
