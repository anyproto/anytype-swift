//
//  IconOnlyObjectHeaderContentView.swift
//  IconOnlyObjectHeaderContentView
//
//  Created by Konstantin Mordan on 09.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import UIKit

final class IconOnlyObjectHeaderContentView: UIView, UIContentView {
    
    private let iconView = DocumentIconView()
    
    private var topConstraint: NSLayoutConstraint!
    
    private var appliedConfiguration: IconOnlyObjectHeaderConfiguration!
    
    // MARK: - Internal variables
    
    var configuration: UIContentConfiguration {
        get { self.appliedConfiguration }
        set {
            guard let configuration = newValue as? IconOnlyObjectHeaderConfiguration,
                  appliedConfiguration != configuration else {
                return
            }
            
            // TODO: implement apply
        }
    }
    
    // MARK: - Initializers
    
    init(configuration: IconOnlyObjectHeaderConfiguration) {
        super.init(frame: .zero)
        
        setupLayout()
        apply(configuration: configuration)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Private extension

private extension IconOnlyObjectHeaderContentView {

    func apply(configuration: IconOnlyObjectHeaderConfiguration) {
        switch configuration.icon {
        case let .icon(icon):
            switch icon {
            case .basic:
                topConstraint.constant = Constants.basicTopInset
            case .profile:
                topConstraint.constant = Constants.profileTopInset
            }
        case let .preview(preview):
            switch preview {
            case .basic:
                topConstraint.constant = Constants.basicTopInset
            case .profile:
                topConstraint.constant = Constants.profileTopInset
            }
        }
    }
    
}

// MARK: - Private extension

private extension IconOnlyObjectHeaderContentView {
    
    func setupLayout() {
        addSubview(iconView) {
            $0.leading.equal(to: leadingAnchor, constant: 20)
            $0.trailing.equal(to: trailingAnchor, constant: 20)
            $0.bottom.equal(to: bottomAnchor, constant: 16)
            topConstraint = $0.top.equal(to: topAnchor)
        }
    }
    
}

private extension IconOnlyObjectHeaderContentView {
    
    enum Constants {
        static let basicTopInset: CGFloat = 72
        static let profileTopInset: CGFloat = 48
    }
    
}
