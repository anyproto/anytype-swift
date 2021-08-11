//
//  ObjectHeaderCoverOnlyConfiguration.swift
//  ObjectHeaderCoverOnlyConfiguration
//
//  Created by Konstantin Mordan on 09.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import UIKit

struct ObjectHeaderCoverOnlyConfiguration: UIContentConfiguration, Hashable {
    
    let cover: ObjectCover
    let maxWidth: CGFloat
    
    func makeContentView() -> UIView & UIContentView {
        ObjectHeaderCoverOnlyContentView(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> Self {
        self
    }
    
}
