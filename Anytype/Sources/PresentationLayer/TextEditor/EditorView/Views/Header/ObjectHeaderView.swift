//
//  ObjectHeaderView.swift
//  ObjectHeaderView
//
//  Created by Konstantin Mordan on 08.09.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import UIKit

final class ObjectHeaderView: UIView {
    
    var onCoverTap: (() -> Void)?
    var onIconTap: (() -> Void)?
    
    private let iconView = UIView()
    private let coverView = NewObjectCoverView()
    
    private var heightConstraint: NSLayoutConstraint!
    private var emptyStateHeightConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension ObjectHeaderView: ConfigurableView {
    
    func configure(model: ObjectHeader) {
        
    }
    
}

private extension ObjectHeaderView {
    
    func setupView() {
        backgroundColor = .grayscaleWhite
        setupLayout()
    }
    
    func setupLayout() {
        layoutUsing.anchors {
            self.heightConstraint = $0.height.equal(
                to: Constants.headerHeight,
                activate: false
            )
            self.emptyStateHeightConstraint = $0.height.equal(
                to: Constants.emptyHeaderHeight,
                activate: false
            )
        }
        
        addSubview(coverView) {
            $0.pinToSuperview(excluding: [.bottom])
            $0.bottom.equal(to: bottomAnchor, constant: Constants.coverBottomInset)
        }
    }
    
}

private extension ObjectHeaderView {
    
    enum Constants {
        static let emptyHeaderHeight: CGFloat = 184
        static let headerHeight: CGFloat = 232
        
        static let coverBottomInset: CGFloat = 32
    }
    
}
