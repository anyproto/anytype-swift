//
//  IconAndCoverObjectHeaderContentView.swift
//  IconAndCoverObjectHeaderContentView
//
//  Created by Konstantin Mordan on 10.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//


import UIKit

final class IconAndCoverObjectHeaderContentView: UIView, UIContentView {
    
    // MARK: - Views
    
    private let iconContentView: IconOnlyObjectHeaderContentView
    private let coverContentView: CoverOnlyObjectHeaderContentView
    
    // MARK: - Private variables
    
    private var appliedConfiguration: IconAndCoverObjectHeaderConfiguration!
    
    // MARK: - Internal variables
    
    var configuration: UIContentConfiguration {
        get { self.appliedConfiguration }
        set {
            guard
                let configuration = newValue as? IconAndCoverObjectHeaderConfiguration,
                appliedConfiguration != configuration
            else {
                return
            }
            
            apply(configuration: configuration)
        }
    }
    
    // MARK: - Initializers
    
    init(configuration: IconAndCoverObjectHeaderConfiguration) {
        self.iconContentView = IconOnlyObjectHeaderContentView(
            configuration: configuration.iconConfiguration
        )
        self.coverContentView = CoverOnlyObjectHeaderContentView(
            configuration: configuration.coverConfiguration
        )
        super.init(frame: .zero)
        
        setupView()
        apply(configuration: configuration)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private extension IconAndCoverObjectHeaderContentView {

    func apply(configuration: IconAndCoverObjectHeaderConfiguration) {
        appliedConfiguration = configuration
        
        iconContentView.configuration = configuration.iconConfiguration
        coverContentView.configuration = configuration.coverConfiguration
    }
    
}

private extension IconAndCoverObjectHeaderContentView {

    func setupView() {
        iconContentView.backgroundColor = .clear
        setupLayout()
    }
    
    func setupLayout() {
        addSubview(coverContentView) {
            $0.pinToSuperview()
        }
        
        addSubview(iconContentView) {
            $0.pinToSuperview()
        }
    }
    
}
