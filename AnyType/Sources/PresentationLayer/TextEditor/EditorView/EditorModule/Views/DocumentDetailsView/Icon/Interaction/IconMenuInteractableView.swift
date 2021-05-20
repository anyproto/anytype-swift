//
//  IconMenuInteractableView.swift
//  Anytype
//
//  Created by Konstantin Mordan on 19.05.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import UIKit.UIView

protocol IconMenuInteractableView: UIView {
    
    func enableMenuInteraction(with onUserAction: @escaping (DocumentIconViewUserAction) -> Void)
    
}
