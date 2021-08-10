//
//  ObjectHeader.swift
//  ObjectHeader
//
//  Created by Konstantin Mordan on 09.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import UIKit

enum ObjectHeader: Hashable {
    
    case iconOnly(ObjectIcon)
    case coverOnly(ObjectCover)
    case iconAndCover(ObjectIcon, ObjectCover)
    
}

extension ObjectHeader: ContentConfigurationProvider {
    
    func makeContentConfiguration(maxWidth: CGFloat) -> UIContentConfiguration {
        switch self {
        case let .iconOnly(objectIcon):
            return IconOnlyObjectHeaderConfiguration(icon: objectIcon)
        case let .coverOnly(objectCover):
            return CoverOnlyObjectHeaderConfiguration(
                cover: objectCover,
                maxWidth: maxWidth
            )
        case let .iconAndCover(objectIcon, objectCover):
            return IconAndCoverObjectHeaderConfiguration(
                iconConfiguration: IconOnlyObjectHeaderConfiguration(
                    icon: objectIcon
                ),
                coverConfiguration: CoverOnlyObjectHeaderConfiguration(
                    cover: objectCover,
                    maxWidth: maxWidth
                )
            )
        }
    }
    
}
