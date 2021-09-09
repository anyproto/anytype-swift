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
    
    // MARK: - Private variables

//    private let iconView = NewObjectIconView()
    private let coverView = NewObjectCoverView()

    private var emptyHeaderHeightConstraint: NSLayoutConstraint!
    private var filledHeaderHeightConstraint: NSLayoutConstraint!
    
    private var leadingConstraint: NSLayoutConstraint!
    private var centerConstraint: NSLayoutConstraint!
    private var trailingConstraint: NSLayoutConstraint!
    
    private var scrollViewTopInset: CGFloat = 0 {
        didSet {
            scrollView?.contentInset.top = scrollViewTopInset
        }
    }
    
    private weak var scrollView: UIScrollView?
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupInScrollView(_ scrollView: UIScrollView) {
        scrollView.contentInset.top = scrollViewTopInset
        
        self.scrollView = scrollView
    }
    
}

extension ObjectHeaderView: ConfigurableView {
    
    func configure(model: ObjectHeader) {
        switch model {
        case .iconOnly(let objectIcon):
            break
        case .coverOnly(let objectCover):
            setupFilledState()
            coverView.configure(model: objectCover)
        case .iconAndCover(let icon, let cover):
            setupFilledState()
            coverView.configure(model: cover)
        case .empty:
            setupEmptyState()
        }
    }
    
}

private extension ObjectHeaderView {
    
    func setupView() {
        backgroundColor = .grayscaleWhite
        setupLayout()
        
        setupEmptyState()
    }
    
    func setupLayout() {
        layoutUsing.anchors {
            self.emptyHeaderHeightConstraint = $0.height.equal(
                to: Constants.emptyHeaderHeight,
                activate: false
            )
            self.filledHeaderHeightConstraint = $0.height.equal(
                to: Constants.filledHeaderHeight,
                activate: false
            )
        }
        
        addSubview(coverView) {
            $0.pinToSuperview(
                insets: UIEdgeInsets(
                    top: 0,
                    left: 0,
                    bottom: -Constants.coverBottomInset,
                    right: 0
                )
            )
        }
        
//        addSubview(iconView) {
//            $0.top.equal(to: topAnchor)
//            $0.bottom.equal(to: bottomAnchor)
//
//            leadingConstraint = $0.leading.equal(
//                to: leadingAnchor,
//                activate: false
//            )
//
//            centerConstraint = $0.centerX.equal(
//                to: centerXAnchor,
//                activate: false
//            )
//            trailingConstraint =  $0.trailing.equal(
//                to: trailingAnchor,
//                activate: false
//            )
//        }
    }
    
    func setupEmptyState() {
        emptyHeaderHeightConstraint.isActive = true
        filledHeaderHeightConstraint.isActive = false
        
        coverView.isHidden = true
        
        scrollViewTopInset = Constants.emptyHeaderHeight
    }
    
    func setupFilledState() {
        emptyHeaderHeightConstraint.isActive = false
        filledHeaderHeightConstraint.isActive = true
        
        coverView.isHidden = false
        
        scrollViewTopInset = Constants.filledHeaderHeight
    }
    
}

private extension ObjectHeaderView {
    
    enum Constants {
        static let emptyHeaderHeight: CGFloat = 184
        static let filledHeaderHeight: CGFloat = 232
        
        static let coverBottomInset: CGFloat = 32
    }
    
}
