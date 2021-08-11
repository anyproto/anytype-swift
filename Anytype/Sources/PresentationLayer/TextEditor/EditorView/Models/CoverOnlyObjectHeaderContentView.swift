//
//  CoverOnlyObjectHeaderContentView.swift
//  CoverOnlyObjectHeaderContentView
//
//  Created by Konstantin Mordan on 09.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import UIKit
import Kingfisher

final class CoverOnlyObjectHeaderContentView: UIView, UIContentView {
    
    // MARK: - Views
    
    private let coverView = ObjectCoverView()
        
    // MARK: - Private variables

    private var appliedConfiguration: CoverOnlyObjectHeaderConfiguration!
    
    // MARK: - Internal variables
    
    var configuration: UIContentConfiguration {
        get { self.appliedConfiguration }
        set {
            guard
                let configuration = newValue as? CoverOnlyObjectHeaderConfiguration,
                appliedConfiguration != configuration
            else {
                return
            }
            
            apply(configuration: configuration)
        }
    }
    
    // MARK: - Initializers
    
    init(configuration: CoverOnlyObjectHeaderConfiguration) {
        super.init(frame: .zero)
        
        setupLayout()
        apply(configuration: configuration)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private extension CoverOnlyObjectHeaderContentView  {
    
    func apply(configuration: CoverOnlyObjectHeaderConfiguration) {
        appliedConfiguration = configuration
        coverView.configure(
            model: (configuration.cover, configuration.maxWidth)
        )
    }
    
    func setupLayout() {
        addSubview(coverView) {
            $0.pinToSuperview()
        }
        
        // Modern collection view requirement
        translatesAutoresizingMaskIntoConstraints = true
    }
}
