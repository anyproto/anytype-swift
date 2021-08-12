//
//  ObjectHeaderEmptyConfiguration.swift
//  ObjectHeaderEmptyConfiguration
//
//  Created by Konstantin Mordan on 12.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import UIKit

struct ObjectHeaderEmptyConfiguration: UIContentConfiguration, Hashable {
    
    func makeContentView() -> UIView & UIContentView {
       ObjectHeaderEmptyContentView(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> Self {
        self
    }
    
}
