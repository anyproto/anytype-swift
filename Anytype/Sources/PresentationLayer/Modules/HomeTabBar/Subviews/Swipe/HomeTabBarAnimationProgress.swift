import Foundation
import SwiftUI

enum HomeTabBarAnimationProgress {
    case readyToShow
    case showInProgress
    case show
    case hiddenInProgress
    
    func opacity(progress: CGFloat) -> CGFloat {
        switch self {
        case .readyToShow:
            0
        case .showInProgress:
            1 * progress
        case .show:
            1
        case .hiddenInProgress:
            1
        }
    }
    
    func zIndex() -> CGFloat {
        switch self {
        case .readyToShow, .showInProgress:
            1
        case .show, .hiddenInProgress:
            2
        }
    }
    
    func offsetX(progress: CGFloat, containerWidth: CGFloat) -> CGFloat {
        switch self {
        case .readyToShow:
            -(containerWidth * 0.3)
        case .showInProgress:
            (containerWidth * 0.3 * progress)-(containerWidth * 0.3)
        case .show:
            0
        case .hiddenInProgress:
            containerWidth * progress
        }
    }
}
