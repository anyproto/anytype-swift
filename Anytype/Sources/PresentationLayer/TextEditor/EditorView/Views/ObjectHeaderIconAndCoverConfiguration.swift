//
//  ObjectHeaderIconAndCoverConfiguration.swift
//  ObjectHeaderIconAndCoverConfiguration
//
//  Created by Konstantin Mordan on 10.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import UIKit

struct ObjectHeaderIconAndCoverConfiguration: UIContentConfiguration, Hashable {
    
    let icon: ObjectIcon
    let cover: ObjectCover
    let maxWidth: CGFloat
    
    func makeContentView() -> UIView & UIContentView {
       ObjectHeaderIconAndCoverContentView(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> Self {
        self
    }
    
}
