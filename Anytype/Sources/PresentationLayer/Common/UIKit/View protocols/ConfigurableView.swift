//
//  ConfigurableView.swift
//  Anytype
//
//  Created by Konstantin Mordan on 11.05.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

/// Describes a view, which can be configured with some model.
protocol ConfigurableView: AnyObject {
    
    associatedtype Model
    
    /// Configures the view with specified model.
    ///
    /// - Parameter model: The model object.
    @MainActor
    func configure(model: Model)
    
}

extension ConfigurableView {
    
    @MainActor
    func configured(with model: Model) -> Self {
        configure(model: model)
        return self
    }
    
}
