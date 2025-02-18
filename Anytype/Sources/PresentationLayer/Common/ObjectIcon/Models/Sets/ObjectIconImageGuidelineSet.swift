import Foundation

struct ObjectIconImageGuidelineSet {
    
    let basicImageGuideline: ImageGuideline?
    let profileImageGuideline: ImageGuideline?
    let emojiImageGuideline: ImageGuideline?
    let todoImageGuideline: ImageGuideline?
    let placeholderImageGuideline: ImageGuideline?
    let staticImageGuideline: ImageGuideline?
    let bookmarkImageGuideline: ImageGuideline?
    let spaceImageGuideline: ImageGuideline?
    
    func imageGuideline(for icon: Icon) -> ImageGuideline? {
        switch icon {
        case .object(let objectIcon):
            switch objectIcon {
            case .basic:
                return basicImageGuideline
            case .profile:
                return profileImageGuideline
            case .emoji:
                return emojiImageGuideline
            case .bookmark:
                return bookmarkImageGuideline
            case .space:
                return spaceImageGuideline
            case .todo:
                return todoImageGuideline
            case .placeholder:
                return placeholderImageGuideline
            case .deleted, .file, .empty:
                return staticImageGuideline
            }
        case .asset:
            return staticImageGuideline
        case .image:
            return staticImageGuideline
        case .url:
            return nil
        }
    }
    
}
