import AnytypeCore
import FloatingPanel
import BlocksModels
import UIKit


final class BottomSheetsFactory {
    static func createStyleBottomSheet(
        parentViewController: UIViewController,
        delegate: FloatingPanelControllerDelegate,
        info: BlockInformation,
        actionHandler: BlockActionHandlerProtocol,
        didShow: @escaping (FloatingPanelController) -> Void,
        showMarkupMenu: @escaping (_ styleView: UIView, _ viewDidClose: @escaping () -> Void) -> Void
    ) {
        let fpc = FloatingPanelController()
        fpc.delegate = delegate
        let appearance = SurfaceAppearance()
        appearance.cornerRadius = 16.0
        // Define shadows
        let shadow = SurfaceAppearance.Shadow()
        shadow.color = UIColor.shadowPrimary
        shadow.offset = CGSize(width: 0, height: 0)
        shadow.radius = 40
        shadow.opacity = 1
        appearance.shadows = [shadow]

        fpc.surfaceView.layer.cornerCurve = .continuous

        fpc.surfaceView.containerMargins = .init(top: 0, left: 10.0, bottom: 44.0, right: 10.0)
        fpc.surfaceView.grabberHandleSize = .init(width: 48.0, height: 4.0)
        fpc.surfaceView.grabberHandle.layer.cornerRadius = 6.0
        fpc.surfaceView.grabberHandle.barColor = .strokePrimary
        fpc.surfaceView.appearance = appearance
        fpc.isRemovalInteractionEnabled = true
        fpc.backdropView.dismissalTapGestureRecognizer.isEnabled = true
        fpc.backdropView.backgroundColor = .clear
        fpc.contentMode = .static

        // NOTE: This will be moved to coordinator in next pr
        guard case let .text(textContentType) = info.content.type else { return }

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

        let restrictions = BlockRestrictionsBuilder.build(content: info.content)

        let contentVC = StyleViewController(
            blockId: info.id,
            viewControllerForPresenting: parentViewController,
            style: textContentType,
            restrictions: restrictions,
            askColor: askColor,
            askBackgroundColor: askBackgroundColor,
            didTapMarkupButton: showMarkupMenu,
            actionHandler: actionHandler
        )
        fpc.layout = StylePanelLayout(layoutGuide: contentVC.layoutGuide)
        
        fpc.set(contentViewController: contentVC)
        fpc.addPanel(toParent: parentViewController, animated: true) {
            didShow(fpc)
        }
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
