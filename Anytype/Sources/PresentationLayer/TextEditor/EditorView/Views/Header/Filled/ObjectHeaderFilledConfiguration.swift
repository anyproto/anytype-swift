//
//  ObjectHeaderFilledConfiguration.swift
//  Anytype
//
//  Created by Konstantin Mordan on 23.09.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import UIKit

struct ObjectHeaderFilledConfiguration: UIContentConfiguration, Hashable {
        
    let header: ObjectHeader
    let width: CGFloat
    
    func makeContentView() -> UIView & UIContentView {
        ObjectHeaderFilledContentView(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> Self {
        return self
    }
}
