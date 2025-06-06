import UIKit
import FloatingPanel

enum AnytypePopupLayoutType {
    case intrinsic
    case fullScreen
    case propertyOptions
    case constantHeight(height: CGFloat, floatingPanelStyle: Bool, needBottomInset: Bool = true)
    case adaptiveTextRelationDetails(layoutGuide: UILayoutGuide)
    case alert(height: CGFloat)

    @MainActor
    var layout: any FloatingPanelLayout {
        switch self {
        case .intrinsic, .alert:
            return IntrinsicPopupLayout()
        case .fullScreen:
            return FullScreenHeightPopupLayout()
        case .propertyOptions:
            return PropertyOptionsPopupLayout()
        case .constantHeight(let height, let floatingPanelStyle, let needBottomInset):
            return ConstantHeightPopupLayout(
                height: height,
                floatingPanelStyle: floatingPanelStyle,
                needBottomInset: needBottomInset
            )
        case .adaptiveTextRelationDetails(let layoutGuide):
            return AdaptiveTextRelationDetailsPopupLayout(layout: layoutGuide)
        }
    }
}
