//
//  UIDeviceExtension.swift
//  Anytype
//
//  Created by Konstantin Mordan on 07.02.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import Foundation
import UIKit

extension UIDevice {
    
    static var isPhone: Bool { UIDevice.current.userInterfaceIdiom == .phone }
    static var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }
    
}
