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
    func customHitTestArea(_ point: CGPoint) -> UIView? {
        let dX = max(minHitTestArea.width - bounds.width, bounds.width) / 2
        let dY = max(minHitTestArea.height - bounds.height, bounds.height) / 2

        return bounds.insetBy(dx: -dX, dy: -dY).contains(point) ? self : nil
    }
}
