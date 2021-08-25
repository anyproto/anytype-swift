//
//  ObjectIconImagePainterProtocol.swift
//  ObjectIconImagePainterProtocol
//
//  Created by Konstantin Mordan on 24.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import UIKit

protocol ObjectIconImagePainterProtocol {
    
    func todoImage(isChecked: Bool, imageGuideline: ImageGuideline) -> UIImage
    func image(with string: String, font: UIFont) -> UIImage?
    
}
