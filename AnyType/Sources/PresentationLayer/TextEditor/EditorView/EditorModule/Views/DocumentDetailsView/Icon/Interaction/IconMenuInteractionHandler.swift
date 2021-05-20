//
//  IconMenuInteractionHandler.swift
//  Anytype
//
//  Created by Konstantin Mordan on 19.05.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import UIKit

final class IconMenuInteractionHandler: NSObject {
    
    // MARK: - Private variables
    
    private weak var targetView: UIView?
    private let onUserAction: (DocumentIconViewUserAction) -> Void
    
    // MARK: - Initializer
    
    init(targetView: UIView?,
         onUserAction: @escaping (DocumentIconViewUserAction) -> Void) {
        self.targetView = targetView
        self.onUserAction = onUserAction
    }
    
}

// MARK: - UIContextMenuInteractionDelegate

extension IconMenuInteractionHandler: UIContextMenuInteractionDelegate {

    func contextMenuInteraction(
       _ interaction: UIContextMenuInteraction,
       configurationForMenuAtLocation location: CGPoint
   ) -> UIContextMenuConfiguration? {
       let actions = DocumentIconViewUserAction.allCases.map { action in
           UIAction(
               title: action.title,
               image: action.icon
           ) { [weak self ] _ in
               self?.onUserAction(action)
           }
       }
       
       return UIContextMenuConfiguration(
           identifier: nil,
           previewProvider: nil,
           actionProvider: { suggestedActions in
               UIMenu(
                   title: "",
                   children: actions
               )
           }
       )
   }

    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        previewForHighlightingMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        guard let targetedView = self.targetView else { return nil }
        
        let parameters = UIPreviewParameters()
        
        
        parameters.visiblePath = UIBezierPath(
            roundedRect: targetedView.bounds,
            cornerRadius: targetedView.layer.cornerRadius
        )
        
        return UITargetedPreview(view: targetedView, parameters: parameters)
    }

}
