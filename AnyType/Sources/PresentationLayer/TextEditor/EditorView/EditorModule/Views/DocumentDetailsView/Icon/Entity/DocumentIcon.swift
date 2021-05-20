//
//  DocumentIcon.swift
//  Anytype
//
//  Created by Konstantin Mordan on 19.05.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import UIKit.UIView

enum DocumentIcon {
    case emoji(IconEmoji)
    case image(String)
}

extension DocumentIcon {
    
    var iconView: IconMenuInteractableView {
        switch self {
        case let .emoji(iconEmoji):
            return DocumentIconEmojiView().configured(with: iconEmoji)
        case let .image(imageId):
            return DocumentIconImageView().configured(with: imageId)
        }
    }
    
}
