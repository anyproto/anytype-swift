//
//  ObjectHeaderIconOnlyConfiguration.swift
//  ObjectHeaderIconOnlyConfiguration
//
//  Created by Konstantin Mordan on 09.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import UIKit

struct ObjectHeaderIconOnlyConfiguration: UIContentConfiguration, Hashable {
    
    let icon: ObjectIcon
    
    func makeContentView() -> UIView & UIContentView {
        ObjectHeaderIconOnlyContentView(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> Self {
        self
    }
    
}
