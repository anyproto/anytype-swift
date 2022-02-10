//
//  GeometryProxyExtensions.swift
//  Anytype
//
//  Created by Konstantin Mordan on 08.02.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import Foundation
import SwiftUI

extension GeometryProxy {
    
    var readableAlertWidth: CGFloat {
        if UIDevice.isPad {
            if UIDevice.current.orientation.isLandscape {
                return size.width * 0.3
            } else {
                return size.width * 0.4
            }
            
        } else {
            return size.width * 0.8
        }
    }
    
}
