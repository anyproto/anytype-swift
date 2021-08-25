//
//  ObjectIconImageFontSet.swift
//  ObjectIconImageFontSet
//
//  Created by Konstantin Mordan on 25.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//
import Foundation
import UIKit

struct ObjectIconImageFontSet {
    
    private let profileImageFont: UIFont?
    private let emojiImageFont: UIFont?
 
    init(profileImageFont: UIFont?,
         emojiImageFont: UIFont?) {
        self.profileImageFont = profileImageFont
        self.emojiImageFont = emojiImageFont
    }
    
    func imageFont(for iconImage: ObjectIconImage) -> UIFont? {
        switch iconImage {
        case .icon(let objectIconType):
            switch objectIconType {
            case .basic:
                return nil
            case .profile:
                return profileImageFont
            case .emoji:
                return emojiImageFont
            }
        case .todo:
            return nil
        }
    }
    
}

