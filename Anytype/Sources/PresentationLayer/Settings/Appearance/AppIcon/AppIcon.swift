import Foundation
import SwiftUI

enum AppIcon: CaseIterable {
    case smile
    case standart
    case eggo
    
    var avaliableIcons: [AppIcon] {
        #if DEBUG || RELEASE_NIGHTLY
        [.smile, .standart, .eggo]
        #else
        [ .smile, .standart]
        #endif
    }
    
    var previewAsset: ImageAsset {
        switch self {
        case .standart: .AppIconsPreview.appIcon
        case .smile: .AppIconsPreview.appIconSmile
        case .eggo: .AppIconsPreview.appIconEgg
        }
    }
    
    var iconName: String? {
        switch self {
        case .standart: nil
        case .smile: "AppIconSmile"
        case .eggo: "AppIconEgg"
        }
    }
}
