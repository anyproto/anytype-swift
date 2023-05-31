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
        
        let askStyle: () -> BlockText.Style? = {
            let uniquedStyles: [BlockText.Style] = infos.compactMap {
                guard case let .text(textContentType) = $0.content.type else { return nil }
                return textContentType
            }.uniqued()
            
            if uniquedStyles.count == 1 {
                return uniquedStyles.first
            } else {
                return nil
            }
        }
        
        let askColor: () -> UIColor? = {
            let uniquedColors: [MiddlewareColor] = infos.compactMap {
                guard case let .text(textContent) = $0.content else { return nil }
                // if we never change block's text color `textContent.color` will be `nil`
                // but in UI we draw it like its `MiddlewareColor.default`
                return textContent.color ?? MiddlewareColor.default
            }.uniqued()
            
            if uniquedColors.count == 1 {
                return UIColor.Dark.uiColor(from: uniquedColors.first!)
            } else {
                return nil
            }
        }
        
        
        let askBackgroundColor: () -> UIColor? = {
            let uniquedBackgroundColors: [MiddlewareColor] = infos.map {
                // if we never change block's background color `backgroundColor` will be `nil`
                // but in UI we draw it like its `MiddlewareColor.default`
                $0.backgroundColor ?? MiddlewareColor.default
            }.uniqued()
            
            if uniquedBackgroundColors.count == 1 {
                return UIColor.VeryLight.uiColor(from: uniquedBackgroundColors.first!)
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
