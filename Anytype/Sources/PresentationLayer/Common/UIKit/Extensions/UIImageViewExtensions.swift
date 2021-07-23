//
//  UIImageViewExtensions.swift
//  Anytype
//
//  Created by Konstantin Mordan on 20.05.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import UIKit.UIImageView

extension UIImageView {
        
    func addDimmedOverlay(with color: UIColor = UIColor(white: 0.0, alpha: 0.32)) {
        let dimmedOverlayView = UIView()
        dimmedOverlayView.backgroundColor = color
        
        addSubview(dimmedOverlayView)
        dimmedOverlayView.layoutUsing.anchors {
            $0.pinToSuperview()
        }
    }
    
}
