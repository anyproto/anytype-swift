//
//  DocumentDetailsView.swift
//  Anytype
//
//  Created by Konstantin Mordan on 11.05.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import Foundation
import UIKit

final class DocumentDetailsView: UICollectionReusableView {
    
    // MARK: - Views

    private let coverView = DocumentCoverView()
    private let iconView = DocumentIconView()

    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupLayout()
    }
    
    // MARK: - Override functions
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        coverView.configure(model: .empty)
        iconView.configure(model: .empty)
    }
    
}

// MARK: - ConfigurableView

extension DocumentDetailsView: ConfigurableView {
    
    func configure(model: DocumentSection) {
        coverView.configure(model: model.coverViewState)
        iconView.configure(model: model.iconViewState)
    }
    
}

// MARK: - Private extension

private extension DocumentDetailsView {
    
    func setupLayout() {
        addSubview(coverView) {
            $0.leading.equal(to: leadingAnchor)
            $0.trailing.equal(to: trailingAnchor)
            $0.top.equal(to: topAnchor, priority: .defaultLow)
            $0.bottom.equal(to: bottomAnchor, constant: -Constants.coverBottomInset)
        }
        
        addSubview(iconView) {
            $0.leading.equal(to: leadingAnchor, constant: Constants.iconEdgeInsets.leading)
            $0.bottom.equal(to: bottomAnchor, constant: -Constants.iconEdgeInsets.bottom)
            $0.top.greaterThanOrEqual(to: topAnchor, constant: Constants.iconEdgeInsets.top, priority: .defaultHigh)
        }
    }
    
}



// MARK: - Constants

private extension DocumentDetailsView {
    
    enum Constants {
        static let coverBottomInset: CGFloat = 36
        static let iconEdgeInsets = NSDirectionalEdgeInsets(
            top: 12,
            leading: 16,
            bottom: 12,
            trailing: 20
        )
    }
    
}
