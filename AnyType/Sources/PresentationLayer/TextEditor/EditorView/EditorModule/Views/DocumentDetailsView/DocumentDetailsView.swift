//
//  DocumentDetailsView.swift
//  Anytype
//
//  Created by Konstantin Mordan on 11.05.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import Foundation
import UIKit
import Combine

final class DocumentDetailsView: UICollectionReusableView {
    
    // MARK: - Views

    private var coverView: UIView?
    private var iconView: UIView?
    
    // MARK: - Variables
    
    private weak var viewModel: DocumentDetailsViewModel?

    // MARK: - Override functions
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        removeCoverView()
        removeIconView()
        
        viewModel = nil
    }
    
}

// MARK: - ConfigurableView

extension DocumentDetailsView: ConfigurableView {
    
    func configure(model: DocumentDetailsViewModel) {
        viewModel = model
        
        configureCoverView(with: model.coverViewModel)
        configureIconView(with: model.iconViewModel)
    }
    
}

// MARK: - Private extension

private extension DocumentDetailsView {
    
    func configureCoverView(with coverViewModel: DocumentCoverViewModel?) {
        removeCoverView()
        
        guard let coverView = coverViewModel?.makeView() else { return }
        
        addSubview(coverView)
        coverView.layoutUsing.anchors {
            $0.leading.equal(to: leadingAnchor)
            $0.trailing.equal(to: trailingAnchor)
            $0.top.equal(to: topAnchor)
            $0.bottom.equal(to: bottomAnchor, constant: -Constants.coverBottomInset)
        }
        
        self.coverView = coverView
    }
    
    func configureIconView(with iconViewModel: DocumentIconViewModel?) {
        removeIconView()
        
        guard let iconView = iconViewModel?.makeView() else { return }
        
        addSubview(iconView)
        iconView.layoutUsing.anchors {
            $0.leading.equal(to: leadingAnchor, constant: Constants.iconEdgeInsets.leading)
            $0.bottom.equal(to: bottomAnchor, constant: -Constants.iconEdgeInsets.bottom)
            $0.top.greaterThanOrEqual(to: topAnchor, constant: Constants.iconEdgeInsets.top)
        }
        
        self.iconView = iconView
    }
    
    func removeCoverView() {
        coverView?.removeFromSuperview()
        coverView = nil
    }
    
    func removeIconView() {
        iconView?.removeFromSuperview()
        iconView = nil
    }
    
}

// MARK: - Constants

private extension DocumentDetailsView {
    
    enum Constants {
        static let coverBottomInset: CGFloat = 36
        static let iconEdgeInsets = NSDirectionalEdgeInsets(
            top: 12,
            leading: 20,
            bottom: 12,
            trailing: 20
        )
    }
    
}
