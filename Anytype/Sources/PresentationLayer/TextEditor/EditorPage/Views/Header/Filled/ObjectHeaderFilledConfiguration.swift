//
//  ObjectHeaderFilledConfiguration.swift
//  Anytype
//
//  Created by Konstantin Mordan on 23.09.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import UIKit

struct ObjectHeaderFilledConfiguration: UIContentConfiguration, Hashable {
        
    let state: ObjectHeaderFilledState
    let width: CGFloat
    var topAdjustedContentInset: CGFloat = 0
    
    func makeContentView() -> UIView & UIContentView {
        ObjectHeaderFilledContentView(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> Self {
        return self
    }
}
