//
//  ObjectIconImage.swift
//  ObjectIconImage
//
//  Created by Konstantin Mordan on 25.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation

enum ObjectIconImage {
    case icon(ObjectIconType)
    case todo(Bool)
}

extension ObjectIconImage {
    
    func imageGuideline(for sizeGroup: ObjectIconImagePosition) -> ImageGuideline? {
        switch self {
        case .icon(let objectIconType):
            switch objectIconType {
            case .basic:
                return BasicObjectIconImageGuidelineFactory.imageGuideline(for: sizeGroup)
            case .profile:
                return ProfileObjectIconImageGuidelineFactory.imageGuideline(for: sizeGroup)
            case .emoji:
                return EmojiObjectIconImageGuidelineFactory.imageGuideline(for: sizeGroup)
            }
        case .todo:
            return TodoObjectIconImageGuidelineFactory.imageGuideline(for: sizeGroup)
        }
    }
    
}
