//
//  AnimatableView.swift
//  AnimatableView
//
//  Created by Konstantin Mordan on 16.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import UIKit

/// Protocol for a view, which can be animated with some ViewAnimator.
public protocol AnimatableView: UIView {}

extension AnimatableView {

    /// Perfrom animation using specific ViewAnimator
    /// - Parameter animator: The object with animation
    public func animate(using animator: ViewAnimator<Self>) {
        animator.animate(self)
    }

}

extension UIView: AnimatableView {}

