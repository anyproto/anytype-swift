import AnytypeCore
import FloatingPanel
import Services
import UIKit

final class BottomSheetsFactory {
    static func createStyleBottomSheet(
        parentViewController: UIViewController,
        infos: [BlockInformation],
        actionHandler: BlockActionHandlerProtocol,
        restrictions: BlockRestrictions,
        showMarkupMenu: @escaping (_ styleView: UIView, _ viewDidClose: @escaping () -> Void) -> Void,
        onDismiss: (() -> Void)? = nil
    ) -> AnytypePopup? {
        // NOTE: This will be moved to coordinator in next pr
        // :(
        
        // For now, multiple style editing allowed only for text blocks because
        // multiple style editing for any kind of blocks reqires UI updates.
        let notTextInfos = infos.filter { !$0.isText }
        guard infos.isNotEmpty, notTextInfos.isEmpty else { return nil }
        
        // TODO: - implement
        let askStyle: () -> BlockText.Style? = {
            return nil
        }
        
        let askColor: () -> UIColor? = {
            let colors: [UIColor] = infos.map { $0.content }.compactMap {
                guard case let .text(textContent) = $0 else { return nil }
                
                return textContent.color.map {
                    UIColor.Dark.uiColor(from: $0)
                }
            }
            
            let uniquedColors = colors.uniqued()
            
            if uniquedColors.count == 1 {
                return uniquedColors.first
            } else {
                return nil
            }
        }
        
        // TODO - fix. does not work
        let askBackgroundColor: () -> UIColor? = {
            let colors: [UIColor] = infos.compactMap {
                return $0.backgroundColor.map {
                    UIColor.VeryLight.uiColor(from: $0)
                }
            }
            let uniquedColors = colors.uniqued()

            if uniquedColors.count == 1 {
                return uniquedColors.first
            } else {
                return nil
            }
        }
        
        let styleView = StyleView(
            blockIds: infos.map { $0.id },
            viewControllerForPresenting: parentViewController,
            style: askStyle(),
            restrictions: restrictions,
            askColor: askColor,
            askBackgroundColor: askBackgroundColor,
            didTapMarkupButton: showMarkupMenu,
            actionHandler: actionHandler
        )

        let popup = AnytypePopup(
            contentView: styleView,
            popupLayout: .intrinsic,
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
        document: BaseDocumentProtocol,
        blockIds: [BlockId],
        actionHandler: BlockActionHandlerProtocol,
        linkToObjectCoordinator: LinkToObjectCoordinatorProtocol,
        viewDidClose: @escaping () -> Void
    ) {
        let viewModel = MarkupViewModel(
            document: document,
            blockIds: blockIds,
            actionHandler: actionHandler,
            linkToObjectCoordinator: linkToObjectCoordinator
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
