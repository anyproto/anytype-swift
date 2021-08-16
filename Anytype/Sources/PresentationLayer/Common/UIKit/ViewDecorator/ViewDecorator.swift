//
//  ViewDecorator.swift
//  ViewDecorator
//
//  Created by Konstantin Mordan on 16.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import UIKit

struct ViewDecorator<View: UIView> {
    
    let decoration: (View) -> Void

    public init(decoration: @escaping (View) -> Void) {
        self.decoration = decoration
    }
    
    public func decorate(_ view: View) {
        decoration(view)
    }
    
}
