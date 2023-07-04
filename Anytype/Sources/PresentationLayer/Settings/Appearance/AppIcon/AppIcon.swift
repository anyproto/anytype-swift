import Foundation
import SwiftUI

enum AppIcon: CaseIterable {
    case oldSchool
    case standart
    case classic
    
    var previewAsset: ImageAsset {
        switch self {
        case .standart: return .AppIconsPreview.appIcon
        case .oldSchool: return .AppIconsPreview.appIconOldSchool
        case .classic: return .AppIconsPreview.appIconClassic
        }
    }
    
    var iconName: String? {
        switch self {
            case .standart: return nil
            case .oldSchool: return "AppIconOldSchool"
            case .classic: return "AppIconClassic"
        }
    }
}
