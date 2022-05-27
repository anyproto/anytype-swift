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

    func showLayoutMenu(cardStyle: ObjectPreviewViewSection.MainSectionItem.CardStyle,
                        onSelect: @escaping (ObjectPreviewViewSection.MainSectionItem.CardStyle) -> Void) {
        let viewModel = ObjectPreviewLayoutMenuViewModel(cardStyle: cardStyle, onSelect: onSelect)
        let view = PopupViewBuilder.createCheckPopup(viewModel: viewModel)
        viewController?.topPresentedController.present(view, animated: true, completion: nil)
    }

    func showIconMenu(iconSize: ObjectPreviewViewSection.MainSectionItem.IconSize,
                      onSelect: @escaping (ObjectPreviewViewSection.MainSectionItem.IconSize) -> Void) {
        let viewModel = ObjectPreviewIconMenuViewModel(iconSize: iconSize, onSelect: onSelect)
        let view = PopupViewBuilder.createCheckPopup(viewModel: viewModel)
        viewController?.topPresentedController.present(view, animated: true, completion: nil)
    }
}
