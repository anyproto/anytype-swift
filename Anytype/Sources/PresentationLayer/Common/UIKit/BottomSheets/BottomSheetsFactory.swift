import AnytypeCore
import FloatingPanel
import BlocksModels
import UIKit

final class BottomSheetsFactory {
    static func createStyleBottomSheet(
        parentViewController: UIViewController,
        info: BlockInformation,
        actionHandler: BlockActionHandlerProtocol,
        restrictions: BlockRestrictions,
        showMarkupMenu: @escaping (_ styleView: UIView, _ viewDidClose: @escaping () -> Void) -> Void,
        onDismiss: (() -> Void)? = nil
    ) -> AnytypePopup? {
        // NOTE: This will be moved to coordinator in next pr
        // :(
        guard case let .text(textContentType) = info.content.type else { return nil }

        let askColor: () -> UIColor? = {
            guard case let .text(textContent) = info.content else { return nil }
            return textContent.color.map {
                UIColor.Text.uiColor(from: $0)
            }
        }
        let askBackgroundColor: () -> UIColor? = {
            return info.backgroundColor.map {
                UIColor.Background.uiColor(from: $0)
            }
        }
        
        let styleView = StyleView(
            blockId: info.id,
            viewControllerForPresenting: parentViewController,
            style: textContentType,
            restrictions: restrictions,
            askColor: askColor,
            askBackgroundColor: askBackgroundColor,
            didTapMarkupButton: showMarkupMenu,
            actionHandler: actionHandler
        )

        let popup = AnytypePopup(
            contentView: styleView,
            floatingPanelStyle: true,
            configuration: .init(
                isGrabberVisible: true,
                dismissOnBackdropView: true,
                skipThroughGestures: false
            ),
            onDismiss: onDismiss
        )

        popup.backdropView.backgroundColor = .clear

        return popup
    }
    
    static func showMarkupBottomSheet(
        parentViewController: UIViewController,
        styleView: UIView,
        selectedMarkups: [MarkupType : AttributeState],
        selectedHorizontalAlignment: [LayoutAlignment : AttributeState],
        onMarkupAction: @escaping (MarkupViewModelAction) -> Void,
        viewDidClose: @escaping () -> Void
    ) {
        let viewModel = MarkupViewModel(
            selectedMarkups: selectedMarkups,
            selectedHorizontalAlignment: selectedHorizontalAlignment,
            onMarkupAction: onMarkupAction
        )
        let viewController = MarkupsViewController(
            viewModel: viewModel,
            viewDidClose: viewDidClose
        )

        viewModel.view = viewController

        parentViewController.embedChild(viewController)

        viewController.view.pinAllEdges(to: parentViewController.view)
        viewController.containerShadowView.layoutUsing.anchors {
            $0.width.equal(to: 240)
            $0.height.equal(to: 158)
            $0.trailing.equal(to: styleView.trailingAnchor, constant: -8)
            $0.top.equal(to: styleView.topAnchor, constant: 8)
        }
    }
}
