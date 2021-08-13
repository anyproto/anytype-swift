//
//  ObjectHeaderCoverOnlyContentView.swift
//  ObjectHeaderCoverOnlyContentView
//
//  Created by Konstantin Mordan on 09.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import UIKit
import Kingfisher

final class ObjectHeaderCoverOnlyContentView: UIView, UIContentView {
    
    // MARK: - Views
    
    private let coverView = ObjectCoverView()
        
    // MARK: - Private variables

    private var appliedConfiguration: ObjectHeaderCoverOnlyConfiguration!
    
    // MARK: - Internal variables
    
    var configuration: UIContentConfiguration {
        get { self.appliedConfiguration }
        set {
            guard
                let configuration = newValue as? ObjectHeaderCoverOnlyConfiguration,
                appliedConfiguration != configuration
            else {
                return
            }
            
            apply(configuration: configuration)
        }
    }
    
    // MARK: - Initializers
    
    init(configuration: ObjectHeaderCoverOnlyConfiguration) {
        super.init(frame: .zero)
        
        setupLayout()
        apply(configuration: configuration)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private extension ObjectHeaderCoverOnlyContentView  {
    
    func apply(configuration: ObjectHeaderCoverOnlyConfiguration) {
        appliedConfiguration = configuration
        coverView.configure(
            model: .init(
                cover: configuration.cover,
                maxWidth: configuration.maxWidth
            )
        )
    }
    
    func setupLayout() {
        addSubview(coverView) {
            $0.pinToSuperview()
        }
    }
    
}
