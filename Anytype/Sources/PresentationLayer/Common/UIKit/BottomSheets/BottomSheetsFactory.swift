import AnytypeCore
import FloatingPanel
import BlocksModels
import UIKit


final class BottomSheetsFactory {
    typealias ActionHandler = (_ action: BlockHandlerActionType) -> Void

    static func createStyleBottomSheet(
        parentViewController: UIViewController,
        delegate: FloatingPanelControllerDelegate,
        information: BlockInformation,
        container: RootBlockContainer,
        actionHandler: EditorActionHandlerProtocol,
        didShow: @escaping (FloatingPanelController) -> Void
    ) {
        let fpc = FloatingPanelController()
        fpc.delegate = delegate
        let appearance = SurfaceAppearance()
        appearance.cornerRadius = 16.0
        // Define shadows
        let shadow = SurfaceAppearance.Shadow()
        shadow.color = UIColor.grayscale90
        shadow.offset = CGSize(width: 0, height: 4)
        shadow.radius = 40
        shadow.opacity = 0.25
        appearance.shadows = [shadow]

        fpc.surfaceView.layer.cornerCurve = .continuous

        fpc.surfaceView.containerMargins = .init(top: 0, left: 10.0, bottom: parentViewController.view.safeAreaInsets.bottom + 6, right: 10.0)
        fpc.surfaceView.grabberHandleSize = .init(width: 48.0, height: 4.0)
        fpc.surfaceView.grabberHandle.barColor = .grayscale30
        fpc.surfaceView.appearance = appearance
        fpc.isRemovalInteractionEnabled = true
        fpc.backdropView.dismissalTapGestureRecognizer.isEnabled = true
        fpc.layout = StylePanelLayout()
        fpc.backdropView.backgroundColor = .clear
        fpc.contentMode = .static

        // NOTE: This will be moved to coordinator in next pr
        guard case let .text(textContentType) = information.content.type else { return }

        let askColor: () -> UIColor? = {
            guard case let .text(textContent) = information.content else { return nil }
            return textContent.color?.color(background: false)
        }
        let askBackgroundColor: () -> UIColor? = {
            return information.backgroundColor?.color(background: true)
        }

        let contentVC = StyleViewController(
            viewControllerForPresenting: parentViewController,
            style: textContentType,
            askColor: askColor,
            askBackgroundColor: askBackgroundColor) { [weak parentViewController] in
            guard let parentViewController = parentViewController else { return }
            BottomSheetsFactory.showMarkupBottomSheet(
                parentViewController: parentViewController,
                container: container,
                blockId: information.id,
                blockActionHandler: actionHandler
            )
        } actionHandler: { action in
            actionHandler.handleAction(action, blockId: information.id)
        }
        
        fpc.set(contentViewController: contentVC)
        fpc.addPanel(toParent: parentViewController, animated: true) {
            didShow(fpc)
        }
    }
    
    static func showMarkupBottomSheet(parentViewController: UIViewController,
                               container: RootBlockContainer,
                               blockId: BlockId,
                               blockActionHandler: EditorActionHandlerProtocol)  {
        guard let rootId = container.rootId else {
            anytypeAssertionFailure("Unable to get context Id")
            return
        }
        let blockInformationCreator = BlockInformationCreator(
            validator: BlockValidator(restrictionsFactory: BlockRestrictionsFactory()),
            container: container
        )
        let viewModel = TextAttributesViewModel(
            actionHandler: blockActionHandler,
            container: container,
            blockId: blockId
        )
        let eventsListener = TextBlockContentChangeListener(
            contenxtId: rootId,
            options: [.blockSetText, .blockSetAlign],
            blockId: blockId,
            blockInformationCreator: blockInformationCreator,
            delegate: viewModel
        )
        viewModel.setEventsListener(eventsListener)
        viewModel.setRange(.whole)
        let attributesViewController = TextAttributesViewController(viewModel: viewModel)
        viewModel.setView(attributesViewController)
        
        let fpc = FloatingPanelController(delegate: attributesViewController)
        let appearance = SurfaceAppearance()
        appearance.cornerRadius = 16.0
        // Define shadows
        let shadow = SurfaceAppearance.Shadow()
        shadow.color = UIColor.grayscale90
        shadow.offset = CGSize(width: 0, height: 4)
        shadow.radius = 40
        shadow.opacity = 0.25
        appearance.shadows = [shadow]

        let sizeDifference = StylePanelLayout.Constant.panelHeight -  TextAttributesPanelLayout.Constant.panelHeight
        fpc.layout = TextAttributesPanelLayout(additonalHeight: sizeDifference)

        let bottomInset = parentViewController.view.safeAreaInsets.bottom + 6 + sizeDifference
        fpc.surfaceView.containerMargins = .init(top: 0, left: 10.0, bottom: bottomInset, right: 10.0)
        fpc.surfaceView.layer.cornerCurve = .continuous
        fpc.surfaceView.grabberHandleSize = .init(width: 48.0, height: 4.0)
        fpc.surfaceView.grabberHandle.barColor = .grayscale30
        fpc.surfaceView.appearance = appearance
        fpc.isRemovalInteractionEnabled = true
        fpc.backdropView.dismissalTapGestureRecognizer.isEnabled = true
        fpc.backdropView.backgroundColor = .clear
        fpc.contentMode = .static
        fpc.set(contentViewController: attributesViewController)
        fpc.addPanel(toParent: parentViewController, animated: true)
    }
}
