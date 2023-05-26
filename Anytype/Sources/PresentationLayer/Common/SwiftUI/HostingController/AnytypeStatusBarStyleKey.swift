import Foundation
import SwiftUI

enum AnytypeStatusBarStyle {
    case `default`
    case lightContent
    case darkContent
    case lightToDarkContent
    case darkToLightContent
    
    func uiKitStyle(traitCollection: UITraitCollection) -> UIStatusBarStyle {
        switch self {
        case .default:
            return .default
        case .lightContent:
            return .lightContent
        case .darkContent:
            return .darkContent
        case .lightToDarkContent:
            switch traitCollection.userInterfaceStyle {
            case .light, .unspecified:
                return .lightContent
            case .dark:
                return .darkContent
            @unknown default:
                return .lightContent
            }
        case .darkToLightContent:
            switch traitCollection.userInterfaceStyle {
            case .light, .unspecified:
                return .darkContent
            case .dark:
                return .lightContent
            @unknown default:
                return .darkContent
            }
        }
    }
}


struct AnytypeStatusBarStyleKey: PreferenceKey {
    static var defaultValue: AnytypeStatusBarStyle = .default
  
    static func reduce(value: inout AnytypeStatusBarStyle, nextValue: () -> AnytypeStatusBarStyle) {
        value = nextValue()
    }
}

extension View {
    func anytypeStatusBar(style: AnytypeStatusBarStyle) -> some View {
        preference(key: AnytypeStatusBarStyleKey.self, value: style)
    }
}
