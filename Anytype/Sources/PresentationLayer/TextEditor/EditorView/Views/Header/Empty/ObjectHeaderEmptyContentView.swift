//
//  ObjectHeaderEmptyContentView.swift
//  ObjectHeaderEmptyContentView
//
//  Created by Konstantin Mordan on 12.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import UIKit

final class ObjectHeaderEmptyContentView: UIView, UIContentView {
        
    // MARK: - Private variables

    private var appliedConfiguration: ObjectHeaderEmptyConfiguration!
    private let tapGesture: BindableGestureRecognizer
    
    // MARK: - Internal variables
    
    var configuration: UIContentConfiguration {
        get { self.appliedConfiguration }
        set { return }
    }
    
    // MARK: - Initializers
    
    init(configuration: ObjectHeaderEmptyConfiguration) {
        appliedConfiguration = configuration
        tapGesture = BindableGestureRecognizer(action: configuration.data.onTap)
        super.init(frame: .zero)
        
        setupLayout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private extension ObjectHeaderEmptyContentView  {
    
    func setupLayout() {
        layoutUsing.anchors {
            $0.height.equal(to: Constants.height)
        }
        translatesAutoresizingMaskIntoConstraints = true
        addGestureRecognizer(tapGesture)
    }
    
}

extension ObjectHeaderEmptyContentView {
    
    enum Constants {
        static let height: CGFloat = 184
    }
    
}
