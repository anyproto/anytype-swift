//
//  IconAndCoverObjectHeaderConfiguration.swift
//  IconAndCoverObjectHeaderConfiguration
//
//  Created by Konstantin Mordan on 10.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import UIKit

struct IconAndCoverObjectHeaderConfiguration: UIContentConfiguration, Hashable {
    
    let icon: ObjectIcon
    let cover: ObjectCover
    let maxWidth: CGFloat
    
    func makeContentView() -> UIView & UIContentView {
       IconAndCoverObjectHeaderContentView(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> Self {
        self
    }
    
}
