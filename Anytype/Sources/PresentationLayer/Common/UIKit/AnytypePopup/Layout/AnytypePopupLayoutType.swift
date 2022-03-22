import UIKit
import FloatingPanel

enum AnytypePopupLayoutType {
    case intrinsic
    case fullScreen
    case relationOptions
    case constantHeight(height: CGFloat, floatingPanelStyle: Bool)
    case adaptiveTextRelationDetails(layoutGuide: UILayoutGuide)
    
    var layout: FloatingPanelLayout {
        switch self {
        case .intrinsic:
            return IntrinsicPopupLayout()
        case .fullScreen:
            return FullScreenHeightPopupLayout()
        case .relationOptions:
            return RelationOptionsPopupLayout()
        case .constantHeight(let height, let floatingPanelStyle):
            return ConstantHeightPopupLayout(height: height, floatingPanelStyle: floatingPanelStyle)
        case .adaptiveTextRelationDetails(let layoutGuide):
            return AdaptiveTextRelationDetailsPopupLayout(layout: layoutGuide)
        }
    }
}
