//
//  EditorRouter.swift
//  Anytype
//
//  Created by Denis Batvinkin on 26.05.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import UIKit


/// Presenting new view on screen in editor
protocol EditorRouterProtocol {
    func showPage(with id: String)
}


final class EditorRouter: EditorRouterProtocol {
    private weak var preseningViewController: UIViewController?

    init(preseningViewController: UIViewController) {
        self.preseningViewController = preseningViewController
    }

    /// Show page
    /// - Parameter id: page id
    func showPage(with id: String) {
        let presentedDocumentView = EditorModuleContainerViewBuilder.view(id: id)
        preseningViewController?.show(presentedDocumentView, sender: nil)
    }
}
