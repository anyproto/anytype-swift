import Foundation
import SwiftUI

enum AppIcon: CaseIterable {
    case smile
    case standart
    case classic
    case oldSchool
    
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
}
