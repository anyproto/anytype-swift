//
//  ObjectHeaderView.swift
//  ObjectHeaderView
//
//  Created by Konstantin Mordan on 08.09.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import UIKit
import BlocksModels

final class ObjectHeaderView: UIView {
    
    var onCoverTap: (() -> Void)?
    var onIconTap: (() -> Void)?
    
    // MARK: - Private variables

    private let iconView = NewObjectIconView()
    private let coverView = NewObjectCoverView()
    
    private(set) var headerHeightConstraint: NSLayoutConstraint!
    
    private var emptyHeaderHeightConstraint: NSLayoutConstraint!
    private var filledHeaderHeightConstraint: NSLayoutConstraint!
    
    private var leadingConstraint: NSLayoutConstraint!
    private var centerConstraint: NSLayoutConstraint!
    private var trailingConstraint: NSLayoutConstraint!
    
    private(set) var scrollViewTopInset: CGFloat = 0 {
        didSet {
            scrollView?.contentInset.top = scrollViewTopInset
        }
    }
    
    private var contentOffsetObservation: NSKeyValueObservation?
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
            setupFilledState(.icon)
            
            iconView.configure(model: objectIcon.asObjectIconViewModel)
            
            handleIconLayoutAlignment(objectIcon.layoutAlignment)
            
        case .coverOnly(let objectCover):
            setupFilledState(.cover)
            
            coverView.configure(model: objectCover)
            
        case .iconAndCover(let objectIcon, let objectCover):
            setupFilledState(.iconAndCover)
            
            iconView.configure(model: objectIcon.asObjectIconViewModel)
            coverView.configure(model: objectCover)
            
            handleIconLayoutAlignment(objectIcon.layoutAlignment)
            
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
        
        fillSubviewsWithRandomColors()
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
        
        addSubview(iconView) {
            $0.bottom.equal(
                to: bottomAnchor,
                constant: -Constants.iconBottomInset
            )

            leadingConstraint = $0.leading.equal(
                to: leadingAnchor,
                constant: Constants.iconHorizontalInset,
                activate: false
            )

            centerConstraint = $0.centerX.equal(
                to: centerXAnchor,
                activate: false
            )
            trailingConstraint =  $0.trailing.equal(
                to: trailingAnchor,
                constant: -Constants.iconHorizontalInset,
                activate: false
            )
        }
    }
    
    func setupEmptyState() {
        emptyHeaderHeightConstraint.isActive = true
        filledHeaderHeightConstraint.isActive = false
        
        headerHeightConstraint = emptyHeaderHeightConstraint
        
        scrollViewTopInset = Constants.emptyHeaderHeight
        
        iconView.isHidden = true
        coverView.isHidden = true
    }
    
    func setupFilledState(_ filledState: FilledState) {
        emptyHeaderHeightConstraint.isActive = false
        filledHeaderHeightConstraint.isActive = true
        
        headerHeightConstraint = filledHeaderHeightConstraint
        scrollViewTopInset = Constants.filledHeaderHeight
        
        switch filledState {
        case .icon:
            iconView.isHidden = false
            coverView.isHidden = true
        case .cover:
            iconView.isHidden = true
            coverView.isHidden = false
        case .iconAndCover:
            iconView.isHidden = false
            coverView.isHidden = false
        }
    }
    
    func handleIconLayoutAlignment(_ layoutAlignment: LayoutAlignment) {
        switch layoutAlignment {
        case .left:
            leadingConstraint.isActive = true
            centerConstraint.isActive = false
            trailingConstraint.isActive = false
        case .center:
            leadingConstraint.isActive = false
            centerConstraint.isActive = true
            trailingConstraint.isActive = false
        case .right:
            leadingConstraint.isActive = false
            centerConstraint.isActive = false
            trailingConstraint.isActive = true
        }
    }
    
}

private extension ObjectHeaderView {
    
    enum FilledState {
        case icon
        case cover
        case iconAndCover
    }
    
}

private extension ObjectIcon {
    
    var layoutAlignment: LayoutAlignment {
        switch self {
        case let .icon(_, layoutAlignment):
            return layoutAlignment
        case let .preview(_, layoutAlignment):
            return layoutAlignment
        }
    }
    
    var asObjectIconViewModel: NewObjectIconView.Model {
        switch self {
        case let .icon(objectIconType, _):
            return NewObjectIconView.Model.iconImageModel(
                .init(
                    iconImage: .icon(objectIconType),
                    usecase: .openedObject
                )
            )
        case let .preview(objectIconPreviewType, _):
            return NewObjectIconView.Model.preview(objectIconPreviewType)
        }
    }
    
}

private extension ObjectHeaderView {
    
    enum Constants {
        static let emptyHeaderHeight: CGFloat = 184
        static let filledHeaderHeight: CGFloat = 264
        
        static let coverBottomInset: CGFloat = 32
        
        static let iconHorizontalInset: CGFloat = 20 - NewObjectIconView.Constants.borderWidth
        static let iconBottomInset: CGFloat = 16 - NewObjectIconView.Constants.borderWidth
    }
    
}
