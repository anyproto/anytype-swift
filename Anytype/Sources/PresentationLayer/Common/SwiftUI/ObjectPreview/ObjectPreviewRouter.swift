import UIKit
import Services

final class ObjectPreviewRouter {
    private let viewController: UIViewController?

    init(viewController: UIViewController?) {
        self.viewController = viewController
    }

    func showLayoutMenu(cardStyle: BlockLink.CardStyle, onSelect: @escaping (BlockLink.CardStyle) -> Void) {
        let viewModel = ObjectPreviewLayoutMenuViewModel(cardStyle: cardStyle, onSelect: onSelect)
        let view = PopupViewBuilder.createCheckPopup(viewModel: viewModel)
        viewController?.topPresentedController.present(view, animated: true, completion: nil)
    }

    func showIconMenu(
        objectLayout: DetailsLayout,
        iconSize: BlockLink.IconSize,
        cardStyle: BlockLink.CardStyle,
        onSelect: @escaping (BlockLink.IconSize) -> Void
    ) {
        let viewModel = ObjectPreviewIconMenuViewModel(
            objectLayout: objectLayout,
            cardStyle: cardStyle,
            currentIconSize: iconSize,
            onSelect: onSelect
        )
        let view = PopupViewBuilder.createCheckPopup(viewModel: viewModel)
        viewController?.topPresentedController.present(view, animated: true, completion: nil)
    }

    func showDescriptionMenu(
        currentDescription: BlockLink.Description,
        onSelect: @escaping (BlockLink.Description) -> Void
    ) {
        let viewModel = ObjectPreviewDescriptionMenuViewModel(
            description: currentDescription,
            onSelect: onSelect
        )
        let view = PopupViewBuilder.createCheckPopup(viewModel: viewModel)
        viewController?.topPresentedController.present(view, animated: true, completion: nil)
    }
}
