import Foundation
import SwiftUI

enum AppIcon: CaseIterable {
    case oldSchool
    case standart
    case classic
    
    var previewAsset: ImageAsset {
        switch self {
        case .standart: return .AppIconsPreview.appIcon
        case .oldSchool: return .AppIconsPreview.oldSchoolAppIcon
        case .classic: return .AppIconsPreview.classicAppIcon
        }
    }
    
    var iconName: String? {
        switch self {
            case .standart: return nil
            case .oldSchool: return "OldSchoolAppIcon"
            case .classic: return "ClassicAppIcon"
        }
    }
}
