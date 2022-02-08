import AnytypeCore
import FloatingPanel
import BlocksModels
import UIKit


final class BottomSheetsFactory {
    static func createStyleBottomSheet(
        parentViewController: UIViewController,
        delegate: FloatingPanelControllerDelegate,
        blockModel: BlockModelProtocol,
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

        fpc.surfaceView.containerMargins = .init(top: 0, left: 10.0, bottom: parentViewController.view.safeAreaInsets.bottom + 6, right: 10.0)
        fpc.surfaceView.grabberHandleSize = .init(width: 48.0, height: 4.0)
        fpc.surfaceView.grabberHandle.barColor = .strokePrimary
        fpc.surfaceView.appearance = appearance
        fpc.isRemovalInteractionEnabled = true
        fpc.backdropView.dismissalTapGestureRecognizer.isEnabled = true
        fpc.layout = StylePanelLayout()
        fpc.backdropView.backgroundColor = .clear
        fpc.contentMode = .static

        // NOTE: This will be moved to coordinator in next pr
        guard case let .text(textContentType) = blockModel.information.content.type else { return }

        let askColor: () -> UIColor? = {
            guard case let .text(textContent) = blockModel.information.content else { return nil }
            return textContent.color.map {
                UIColor.Text.uiColor(from: $0)
            }
        }
        let askBackgroundColor: () -> UIColor? = {
            return blockModel.information.backgroundColor.map {
                UIColor.Background.uiColor(from: $0)
            }
        }

        let restrictions = BlockRestrictionsBuilder.build(content: blockModel.information.content)

        let contentVC = StyleViewController(
            blockId: blockModel.information.id,
            viewControllerForPresenting: parentViewController,
            style: textContentType,
            restrictions: restrictions,
            askColor: askColor,
            askBackgroundColor: askBackgroundColor,
            didTapMarkupButton: showMarkupMenu,
            actionHandler: actionHandler
        )
        
        fpc.set(contentViewController: contentVC)
        fpc.addPanel(toParent: parentViewController, animated: true) {
            didShow(fpc)
        }
    }
    
    static func showMarkupBottomSheet(
        parentViewController: UIViewController,
        styleView: UIView,
        blockInformation: BlockInformation,
        viewModel: MarkupViewModel,
        viewDidClose: @escaping () -> Void
    ) {
        viewModel.blockInformation = blockInformation
        viewModel.setRange(.whole)
        let markupsViewController = MarkupsViewController(viewModel: viewModel, viewDidClose: viewDidClose)
        viewModel.view = markupsViewController

        parentViewController.embedChild(markupsViewController)

        markupsViewController.view.pinAllEdges(to: parentViewController.view)
        markupsViewController.containerShadowView.layoutUsing.anchors {
            $0.width.equal(to: 260)
            $0.height.equal(to: 176)
            $0.trailing.equal(to: styleView.trailingAnchor, constant: -10)
            $0.top.equal(to: styleView.topAnchor, constant: -8)
        }
    }
}
