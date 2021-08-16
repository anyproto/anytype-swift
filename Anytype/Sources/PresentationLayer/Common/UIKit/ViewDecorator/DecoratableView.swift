//
//  DecoratableView.swift
//  DecoratableView
//
//  Created by Konstantin Mordan on 16.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import UIKit

/// Describes a view, which can be instantiated and modified with some ViewDecorator.
protocol DecoratableView: UIView {}

extension DecoratableView {
    
    /// Initializes the view with the specified decorator.
    ///
    /// - Parameter decorator: The decorator object to modify the view.
    init(decorator: ViewDecorator<Self>) {
        self.init(frame: .zero)
        decorate(with: decorator)
    }
    
    /// Modifies the view with the specified decorator.
    ///
    /// - Parameter decorator: The decorator object to modify the view.
    /// - Returns: A modified view object.
    @discardableResult
    func decorated(with decorator: ViewDecorator<Self>) -> Self {
        decorate(with: decorator)
        return self
    }
    
    /// Modifies the view with the specified decorator.
    ///
    /// - Parameter decorator: The decorator object to modify the view.
    func decorate(with decorator: ViewDecorator<Self>) {
        decorator.decorate(self)        
    }
    
}

extension UIView: DecoratableView {}
