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
    
    func todoImage(isChecked: Bool) -> UIImage?
    func emojiImage(_ emoji: IconEmoji) -> UIImage?
    func profilePlaceholderImage(character: Character) -> UIImage?
    
}
