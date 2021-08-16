//
//  UIBarButtonItemExtensions.swift
//  UIBarButtonItemExtensions
//
//  Created by Konstantin Mordan on 16.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import UIKit

extension UIBarButtonItem {
    
    static func back(withBackground: Bool, action: @escaping () -> Void) -> UIBarButtonItem? {
        editorBarButtonItem(with: .backArrow, withBackground: withBackground, action: action )
    }
    
    static func settings(withBackground: Bool, action: @escaping () -> Void) -> UIBarButtonItem? {
        editorBarButtonItem(with: .more, withBackground: withBackground, action: action)
    }
    
    private static func editorBarButtonItem(with image: UIImage?, withBackground: Bool, action: @escaping () -> Void) -> UIBarButtonItem? {
        let backgroundView = UIView()
        backgroundView.backgroundColor = withBackground ? .black.withAlphaComponent(0.35) : .clear
        backgroundView.clipsToBounds = true
        backgroundView.layer.cornerRadius = 7
        backgroundView.layoutUsing.anchors {
            $0.size(CGSize(width: 28, height: 28))
        }
                
        let button = UIButton(type: .system)
        button.setImage(image, for: .normal)
        button.tintColor = UIColor.grayscaleWhite
        button.addAction(
            UIAction(
                handler: {_ in
                    action()
                }
            ),
            for: .touchUpInside
        )
        
        backgroundView.addSubview(button) {
            $0.pinToSuperview()
        }
        
        return UIBarButtonItem(customView: backgroundView)
    }
    
}
