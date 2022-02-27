//
//  StylePanelLayout.swift
//  AnyType
//
//  Created by Denis Batvinkin on 21.04.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import FloatingPanel
import CoreGraphics
import UIKit


final class StylePanelLayout: FloatingPanelLayout {
    private let layoutGuide: UILayoutGuide

    init(layoutGuide: UILayoutGuide) {
        self.layoutGuide = layoutGuide
    }

    let initialState: FloatingPanelState = .full
    let position: FloatingPanelPosition = .bottom

    var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] {
        return [
            .full: FloatingPanelAdaptiveLayoutAnchor(absoluteOffset: 0, contentLayout: layoutGuide),
        ]
    }
}
