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
    
    var onHeightUpdate: ((CGFloat) -> Void)?
    
    private(set) var height: CGFloat = 0 {
        didSet {
            onHeightUpdate?(height)
            heightConstraint.constant = height
        }
    }
    
    private(set) var heightConstraint: NSLayoutConstraint!

    // MARK: - Private variables

    private let iconView = ObjectIconView()
    private let coverView = ObjectCoverView()
        
    private var leadingConstraint: NSLayoutConstraint!
    private var centerConstraint: NSLayoutConstraint!
    private var trailingConstraint: NSLayoutConstraint!
        
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
        backgroundColor = .backgroundPrimary
        setupGestureRecognizers()
        
        setupLayout()
        
        setupEmptyState()
    }
    
    func setupGestureRecognizers() {
        iconView.addGestureRecognizer(
            TapGestureRecognizerWithClosure { [weak self] in
                self?.onIconTap?()
            }
        )
        
        addGestureRecognizer(
            TapGestureRecognizerWithClosure { [weak self] in
                self?.onCoverTap?()
            }
        )
    }
    
    func setupLayout() {
        layoutUsing.anchors {
            self.heightConstraint = $0.height.equal(to: 0)
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
        height = Constants.emptyHeaderHeight
        
        iconView.isHidden = true
        coverView.isHidden = true
    }
    
    func setupFilledState(_ filledState: FilledState) {
        height = Constants.filledHeaderHeight

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
    
    var asObjectIconViewModel: ObjectIconView.Model {
        switch self {
        case let .icon(objectIconType, _):
            return ObjectIconView.Model.iconImageModel(
                .init(
                    iconImage: .icon(objectIconType),
                    usecase: .openedObject
                )
            )
        case let .preview(objectIconPreviewType, _):
            return ObjectIconView.Model.preview(objectIconPreviewType)
        }
    }
    
}

extension ObjectHeaderView {
    
    enum Constants {
        static let emptyHeaderHeight: CGFloat = 184
        static let filledHeaderHeight: CGFloat = 264
        
        static let coverBottomInset: CGFloat = 32
        
        static let iconHorizontalInset: CGFloat = 20 - ObjectIconView.Constants.borderWidth
        static let iconBottomInset: CGFloat = 16 - ObjectIconView.Constants.borderWidth
    }
    
}
