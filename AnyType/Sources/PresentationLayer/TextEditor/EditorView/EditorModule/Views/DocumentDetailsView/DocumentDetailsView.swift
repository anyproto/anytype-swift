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

    private var iconView: UIView?
    
    // MARK: - Variables
    
    private weak var viewModel: DocumentDetailsViewModel?

    // MARK: - Override functions
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        removeIconView()
        
        viewModel = nil
    }
    
}

// MARK: - ConfigurableView

extension DocumentDetailsView: ConfigurableView {
    
    func configure(model: DocumentDetailsViewModel) {
        viewModel = model
        
        configureIconView(with: model.documentIcon)
    }
    
}

// MARK: - Private extension

private extension DocumentDetailsView {
    
    func configureIconView(with icon: DocumentIcon?) {
        removeIconView()
        
        guard let icon = icon else { return }
        
        let view = icon.iconView
        view.enableMenuInteraction { [weak self] action in
            self?.viewModel?.handleIconUserAction(action)
        }
        
        iconView = view
    
        setupIconLayout()
    }
    
    func setupIconLayout() {
        guard let iconView = iconView else { return }
        
        addSubview(iconView)
        
        iconView.layoutUsing.anchors {
            $0.leading.equal(to: self.leadingAnchor, constant: Constants.edgeInsets.leading)
            $0.bottom.equal(to: self.bottomAnchor, constant: -Constants.edgeInsets.bottom)
            $0.top.equal(to: self.topAnchor, constant: Constants.edgeInsets.top)
        }
    }
    
    func removeIconView() {
        iconView?.removeFromSuperview()
        iconView = nil
    }
    
}

// MARK: - Constants

private extension DocumentDetailsView {
    
    enum Constants {
        static let edgeInsets = NSDirectionalEdgeInsets(
            top: 12,
            leading: 20,
            bottom: 12,
            trailing: 20
        )
    }
    
}
