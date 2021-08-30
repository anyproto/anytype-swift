//
//  ImageBuilderNEWProtocol.swift
//  ImageBuilderNEWProtocol
//
//  Created by Konstantin Mordan on 30.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import UIKit

protocol ImageBuilderNEWProtocol {
    
    func setImageColor(_ imageColor: UIColor) -> ImageBuilderNEWProtocol
    func setText(_ text: String) -> ImageBuilderNEWProtocol
    func setTextColor(_ textColor: UIColor) -> ImageBuilderNEWProtocol
    func setFont(_ font: UIFont) -> ImageBuilderNEWProtocol
    
    func build() -> UIImage
    
}
