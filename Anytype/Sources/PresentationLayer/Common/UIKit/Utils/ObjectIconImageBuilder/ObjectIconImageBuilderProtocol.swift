//
//  ObjectIconImageBuilderProtocol.swift
//  ObjectIconImageBuilderProtocol
//
//  Created by Konstantin Mordan on 19.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import UIKit

protocol ObjectIconImageBuilderProtocol {
    
    func iconImage(from iconType: DocumentIconType,
                   size: ObjectIconImageSize,
                   onCompletion: @escaping (UIImage?) -> Void)
    
}
