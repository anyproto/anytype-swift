import Foundation
import SwiftUI

enum AppIcon: CaseIterable {
    case smile
    case standart
    
    var previewAsset: ImageAsset {
        switch self {
        case .standart: return .AppIconsPreview.appIcon
        case .smile: return .AppIconsPreview.appIconSmile
        }
    }
    
    var iconName: String? {
        switch self {
        case .standart: return nil
        case .smile: return "AppIconSmile"
        }
    }
}
