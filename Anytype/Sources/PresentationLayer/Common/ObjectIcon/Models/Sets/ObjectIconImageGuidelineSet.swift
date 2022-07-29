import Foundation

struct ObjectIconImageGuidelineSet {
    
    let basicImageGuideline: ImageGuideline?
    let profileImageGuideline: ImageGuideline?
    let emojiImageGuideline: ImageGuideline?
    let todoImageGuideline: ImageGuideline?
    let placeholderImageGuideline: ImageGuideline?
    let staticImageGuideline: ImageGuideline?
    
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
        case .placeholder:
            return placeholderImageGuideline
        case .imageAsset:
            return staticImageGuideline
        case .image:
            return nil
        }
    }
    
}
