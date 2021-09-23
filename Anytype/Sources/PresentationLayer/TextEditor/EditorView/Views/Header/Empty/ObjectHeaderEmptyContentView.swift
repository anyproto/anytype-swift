//
//  ObjectHeaderEmptyContentView.swift
//  Anytype
//
//  Created by Konstantin Mordan on 23.09.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import UIKit

final class ObjectHeaderEmptyContentView: UIView, UIContentView {
        
    // MARK: - Private variables

    private var appliedConfiguration: ObjectHeaderEmptyConfiguration!
    
    // MARK: - Internal variables
    
    var configuration: UIContentConfiguration {
        get { self.appliedConfiguration }
        set { return }
    }
    
    // MARK: - Initializers
    
    init(configuration: ObjectHeaderEmptyConfiguration) {
        appliedConfiguration = configuration
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
    }
    
}

extension ObjectHeaderEmptyContentView {
    
    enum Constants {
        static let height: CGFloat = 184
    }
    
}
