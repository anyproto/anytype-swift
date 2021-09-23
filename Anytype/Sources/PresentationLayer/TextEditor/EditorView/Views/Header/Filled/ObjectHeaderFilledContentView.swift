//
//  ObjectHeaderFilledContentView.swift
//  Anytype
//
//  Created by Konstantin Mordan on 23.09.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import UIKit

final class ObjectHeaderFilledContentView: UIView, UIContentView {
        
    // MARK: - Views
        
    private let headerView = ObjectHeaderView()
    
    // MARK: - Private variables

    private var appliedConfiguration: ObjectHeaderFilledConfiguration!
    
    // MARK: - Internal variables
    
    var configuration: UIContentConfiguration {
        get { self.appliedConfiguration }
        set {
            guard
                let configuration = newValue as? ObjectHeaderFilledConfiguration,
                appliedConfiguration != configuration
            else {
                return
            }
            
            apply(configuration)
        }
    }
    
    // MARK: - Initializers
    
    init(configuration: ObjectHeaderFilledConfiguration) {
        super.init(frame: .zero)
        
        setupLayout()
        apply(configuration)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private extension ObjectHeaderFilledContentView  {
    
    func setupLayout() {
        addSubview(headerView) {
            $0.pinToSuperview()
        }
        
        layoutUsing.anchors {
            $0.height.equal(to: Constants.height)
        }
        translatesAutoresizingMaskIntoConstraints = true
    }
    
    func apply(_ configuration: ObjectHeaderFilledConfiguration) {
        appliedConfiguration = configuration
        headerView.configure(model: configuration.header)
    }
    
}

extension ObjectHeaderFilledContentView {
    
    enum Constants {
        static let height: CGFloat = 184
    }
    
}
