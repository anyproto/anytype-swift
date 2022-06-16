import UIKit
import FloatingPanel

enum AnytypePopupLayoutType {
    case intrinsic
    case fullScreen
    case relationOptions
    case sortOptions
    case constantHeight(height: CGFloat, floatingPanelStyle: Bool)
    case adaptiveTextRelationDetails(layoutGuide: UILayoutGuide)
    case alert(height: CGFloat)

    var layout: FloatingPanelLayout {
        switch self {
        case .intrinsic, .alert:
            return IntrinsicPopupLayout()
        case .fullScreen:
            return FullScreenHeightPopupLayout()
        case .relationOptions:
            return RelationOptionsPopupLayout()
        case .sortOptions:
            return SortOptionsPopupLayout()
        case .constantHeight(let height, let floatingPanelStyle):
            return ConstantHeightPopupLayout(height: height, floatingPanelStyle: floatingPanelStyle)
        case .adaptiveTextRelationDetails(let layoutGuide):
            return AdaptiveTextRelationDetailsPopupLayout(layout: layoutGuide)
        }
    }
}
