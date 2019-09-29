//
//  UIViewExtension.swift
//  AnyType
//
//  Created by Denis Batvinkin on 20.08.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import UIKit


extension UIView {
    
    func renderedImage(rect: CGRect) -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: rect)
        
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}
