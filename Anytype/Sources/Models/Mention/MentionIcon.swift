//
//  MentionIcon.swift
//  Anytype
//
//  Created by Konstantin Mordan on 19.07.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

enum MentionIcon {
    case objectIcon(DocumentIconType)
    case checkmark(Bool)
}

extension MentionIcon {
    
    init?(emoji: String) {
        guard let emoji = IconEmoji(emoji) else { return nil }
        
        self = .objectIcon(.emoji(emoji))
    }
    
}
