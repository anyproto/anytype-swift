//
//  StylePanelLayout.swift
//  AnyType
//
//  Created by Denis Batvinkin on 21.04.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import FloatingPanel
import CoreGraphics


final class StylePanelLayout: FloatingPanelLayout {
    enum Constant {
        static let panelHeight: CGFloat = 238
    }

    var position: FloatingPanelPosition = .bottom
    var initialState: FloatingPanelState = .full

    var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] {
        return [
            .full: FloatingPanelLayoutAnchor(absoluteInset: Constant.panelHeight, edge: .bottom, referenceGuide: .safeArea),
        ]
    }
}
