//
//  StyleColorPanelLayout.swift
//  AnyType
//
//  Created by Denis Batvinkin on 28.04.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import FloatingPanel
import CoreGraphics


final class StyleColorPanelLayout: FloatingPanelLayout {
    enum Constant {
        static let panelHeight: CGFloat = 194
    }

    private var additonalHeight: CGFloat = 0

    var position: FloatingPanelPosition = .bottom
    var initialState: FloatingPanelState = .full

    var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] {
        return [
            .full: FloatingPanelLayoutAnchor(absoluteInset: Constant.panelHeight + additonalHeight, edge: .bottom, referenceGuide: .safeArea),
        ]
    }

    init(additonalHeight: CGFloat) {
        self.additonalHeight = additonalHeight
    }
}
