//
//  QuoteBlockLeadingView.swift
//  AnyType
//
//  Created by Kovalev Alexander on 26.02.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import UIKit

/// View with vertical line pinned to the right side
final class QuoteBlockLeadingView: UIView {
    
    private enum Constants {
        static let lineWidth: CGFloat = 2
    }
    
    private let lineLayer: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor.highlighterColor.cgColor
        return layer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        self.layer.addSublayer(lineLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        lineLayer.frame = CGRect(origin: .init(x: bounds.width - Constants.lineWidth,
                                               y: 0),
                                 size: .init(width: Constants.lineWidth,
                                             height: bounds.height))
    }
}
