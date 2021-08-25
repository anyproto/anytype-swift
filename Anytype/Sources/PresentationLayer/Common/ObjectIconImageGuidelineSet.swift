//
//  ObjectIconImageGuidelineSet.swift
//  ObjectIconImageGuidelineSet
//
//  Created by Konstantin Mordan on 25.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation

struct ObjectIconImageGuidelineSet {
    
    private let basicImageGuideline: ImageGuideline?
    private let profileImageGuideline: ImageGuideline?
    private let emojiImageGuideline: ImageGuideline?
    private let todoImageGuideline: ImageGuideline?
 
    init(basicImageGuideline: ImageGuideline?,
         profileImageGuideline: ImageGuideline?,
         emojiImageGuideline: ImageGuideline?,
         todoImageGuideline: ImageGuideline?) {
        self.basicImageGuideline = basicImageGuideline
        self.profileImageGuideline = profileImageGuideline
        self.emojiImageGuideline = emojiImageGuideline
        self.todoImageGuideline = todoImageGuideline
    }
    
    func imageGuideline(for iconImage: ObjectIconImage) -> ImageGuideline? {
        switch iconImage {
        case .icon(let objectIconType):
            switch objectIconType {
            case .basic:
                return basicImageGuideline
            case .profile:
                return profileImageGuideline
            case .emoji:
                return emojiImageGuideline
            }
        case .todo:
            return todoImageGuideline
        }
    }
    
}
