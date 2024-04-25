import Foundation
import UIKit

struct ObjectIconImageFontSet {
    
    private let profileImageFont: UIFont?
    private let emojiImageFont: UIFont?
    private let placeholderImageFont: UIFont?
    private let spaceImageFont: UIFont?
    
    init(profileImageFont: UIFont?,
         emojiImageFont: UIFont?,
         placeholderImageFont: UIFont?,
         spaceImageFont: UIFont?) {
        self.profileImageFont = profileImageFont
        self.emojiImageFont = emojiImageFont
        self.placeholderImageFont = placeholderImageFont
        self.spaceImageFont = spaceImageFont
    }
    
    func imageFont(for iconImage: Icon) -> UIFont? {
        switch iconImage {
        case .object(let ObjectIcon):
            switch ObjectIcon {
            case .basic, .bookmark:
                return nil
            case .profile:
                return profileImageFont
            case .emoji:
                return emojiImageFont
            case .space:
                return spaceImageFont
            case .todo, .deleted, .file:
                return nil
            case .placeholder:
                return placeholderImageFont
            }
        case .image, .asset:
            return nil
        }
    }
    
}

