//
//  ObjectPreviewRouter.swift
//  Anytype
//
//  Created by Denis Batvinkin on 30.03.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import UIKit
import BlocksModels

final class ObjectPreviewRouter {
    private let viewController: UIViewController?

    init(viewController: UIViewController?) {
        self.viewController = viewController
    }

    func showLayoutMenu(cardStyle: ObjectPreviewModel.CardStyle,
                        onSelect: @escaping (ObjectPreviewModel.CardStyle) -> Void) {
        let viewModel = ObjectPreviewLayoutMenuViewModel(cardStyle: cardStyle, onSelect: onSelect)
        let view = PopupViewBuilder.createCheckPopup(viewModel: viewModel)
        viewController?.topPresentedController.present(view, animated: true, completion: nil)
    }

    func showIconMenu(iconSize: ObjectPreviewModel.IconSize,
                      cardStyle: ObjectPreviewModel.CardStyle,
                      onSelect: @escaping (ObjectPreviewModel.IconSize) -> Void) {
        let viewModel = ObjectPreviewIconMenuViewModel(iconSize: iconSize,
                                                       cardStyle: cardStyle,
                                                       onSelect: onSelect)
        let view = PopupViewBuilder.createCheckPopup(viewModel: viewModel)
        viewController?.topPresentedController.present(view, animated: true, completion: nil)
    }

    func showDescriptionMenu(currentDescription: ObjectPreviewModel.Description,
                             onSelect: @escaping (ObjectPreviewModel.Description) -> Void) {
        let viewModel = ObjectPreviewDescriptionMenuViewModel(description: currentDescription,
                                                              onSelect: onSelect)
        let view = PopupViewBuilder.createCheckPopup(viewModel: viewModel)
        viewController?.topPresentedController.present(view, animated: true, completion: nil)
    }
}
