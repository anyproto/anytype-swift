//
//  CustomizableHitTestArea.swift
//  Anytype
//
//  Created by Denis Batvinkin on 27.09.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import UIKit


protocol CustomizableHitTestAreaView: UIView {
    var minHitTestArea: CGSize { get }
}

extension CustomizableHitTestAreaView {
    func containsCustomHitTestArea(_ point: CGPoint) -> Bool {
        let dX: CGFloat = max(minHitTestArea.width - bounds.width, 0.0) / 2.0
        let dY: CGFloat = max(minHitTestArea.height - bounds.height, 0.0) / 2.0

        return bounds.insetBy(dx: -dX, dy: -dY).contains(point)
    }
}
