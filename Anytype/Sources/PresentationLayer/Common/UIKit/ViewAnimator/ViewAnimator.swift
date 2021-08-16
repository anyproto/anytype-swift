//
//  ViewAnimator.swift
//  ViewAnimator
//
//  Created by Konstantin Mordan on 16.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import UIKit

/// The structure for storing and applying animation.
public struct ViewAnimator<View: UIView> {
    
    let animation: (View) -> Void
    
    public func animate(_ view: View) {
        animation(view)
    }
    
}
