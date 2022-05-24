//
//  ObjectPreviewRouter.swift
//  Anytype
//
//  Created by Denis Batvinkin on 30.03.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import UIKit

final class ObjectPreviewRouter {
    private let viewController: UIViewController?

    init(viewController: UIViewController?) {
        self.viewController = viewController
    }

    func showLayoutMenu(objectPreviewFields: ObjectPreviewFields, onSelect: @escaping (ObjectPreviewFields) -> Void) {
        let viewModel = ObjectPreviewLayoutMenuViewModel(objectPreviewFields: objectPreviewFields, onSelect: onSelect)
        let view = PopupViewBuilder.createCheckPopup(viewModel: viewModel)
        viewController?.topPresentedController.present(view, animated: true, completion: nil)
    }

    func showIconMenu(objectPreviewFields: ObjectPreviewFields, onSelect: @escaping (ObjectPreviewFields) -> Void) {
        let viewModel = ObjectPreviewIconMenuViewModel(objectPreviewFields: objectPreviewFields, onSelect: onSelect)
        let view = PopupViewBuilder.createCheckPopup(viewModel: viewModel)
        viewController?.topPresentedController.present(view, animated: true, completion: nil)
    }
}
