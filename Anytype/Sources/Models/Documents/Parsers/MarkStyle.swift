import UIKit

enum MarkStyle: Equatable {
    enum Update {
        case empty
        case change([NSAttributedString.Key : Any])
        case changeAndDeletedKeys([NSAttributedString.Key : Any], [NSAttributedString.Key])
        func attributes() -> [NSAttributedString.Key : Any] {
            switch self {
            case .empty: return [:]
            case let .change(value): return value
            case let .changeAndDeletedKeys(value, _): return value
            }
        }
        func deletedKeys() -> [NSAttributedString.Key] {
            switch self {
            case .empty: return []
            case .change: return []
            case let .changeAndDeletedKeys(_, keys): return keys
            }
        }
    }
    
    // change font to bold
    // turn on, turn off
    // NSAttributedString.Key.font
    case bold(Bool = true)
    
    // change font to italic
    // turn on, turn off
    // NSAttributedString.Key.font
    case italic(Bool = true)
    
    // change font to ???
    // change paragraphStyle to .keyboard
    // turn on, turn off
    // NSAttributedString.Key.font
    // NSAttributedString.Key.paragraphStyle
    case keyboard(Bool = true)
    
    // style also?
    // turn on, turn off
    // NSAttributedString.Key.strikethroughStyle
    case strikethrough(Bool = true)
    
    // style also?
    // turn on, turn off
    // NSAttributedString.Key.underlineStyle
    case underscored(Bool = true)
    
    
    // choose colors
    // NSAttributedString.Key.foregroundColor
    case textColor(UIColor?)
    
    // choose colors
    // NSAttributedString.Key.backgroundColor
    case backgroundColor(UIColor?)
    
    // NOTE: It has DIFFERENT attributes.
    // Actually, .linkAttributes in UITextView.
    // set link
    // NSAttributedString.Key.link
    case link(URL?)
    
    case mention(String?)
    
    // CAUTION:
    // This method return ONLY SLIDES of correspoding attributes and can return empty dictionary.
    // Second value in a pair is keys to remove.
    func to(old: [NSAttributedString.Key : Any], nonCodeFont: UIFont) -> Update {
        switch self {
        case let .bold(value):
            if let font = old[.font] as? UIFont {
                let oldTraits = font.fontDescriptor.symbolicTraits
                let traits = value ? oldTraits.union(.traitBold) : oldTraits.symmetricDifference(.traitBold)
                if let newDescriptor = font.fontDescriptor.withSymbolicTraits(traits) {
                    let newFont: UIFont = .init(descriptor: newDescriptor, size: font.pointSize)
                    return .change([.font : newFont])
                }
            }
            return .empty
        case let .italic(value):
            if let font = old[.font] as? UIFont {
                let oldTraits = font.fontDescriptor.symbolicTraits
                let traits = value ? oldTraits.union(.traitItalic) : oldTraits.symmetricDifference(.traitItalic)
                if let newDescriptor = font.fontDescriptor.withSymbolicTraits(traits) {
                    let newFont: UIFont = .init(descriptor: newDescriptor, size: font.pointSize)
                    return .change([.font : newFont])
                }
            }
            return .empty
        case let .keyboard(hasStyle):
            return keyboardUpdate(
                with: old,
                shouldHaveStyle: hasStyle,
                nonCodeFont: nonCodeFont
            )
        case let .strikethrough(value): return .change([.strikethroughStyle : value ? 1 : 0])
        case let .underscored(value): return .change([ .underlineStyle : value ? 1 : 0 ])
        case let .textColor(value): return .change([ .foregroundColor : value as Any ])
        case let .backgroundColor(value): return .change([ .backgroundColor : value as Any ])
        case let .link(value): return .changeAndDeletedKeys([ .link : value as Any ], value.isNil ? [.link] : [])
        case let .mention(pageId): return .change([.mention: pageId as Any])
        }
    }
    
    private func keyboardUpdate(
        with attributes: [NSAttributedString.Key: Any],
        shouldHaveStyle: Bool,
        nonCodeFont: UIFont
    ) -> Update {
        guard let font = attributes[.font] as? UIFont else { return .empty }
        
        var targetFont: UIFont
        switch (font.isCode, shouldHaveStyle) {
        case (true, true):
            return .change([.font: font])
        case (true, false):
            targetFont = nonCodeFont
        case (false, true):
            targetFont = UIFont.code(of: font.pointSize)
        case (false, false):
            return .change([.font: font])
        }
        
        var traitsToApply = targetFont.fontDescriptor.symbolicTraits
        if font.fontDescriptor.symbolicTraits.contains(.traitBold) {
            traitsToApply.insert(.traitBold)
        }
        if font.fontDescriptor.symbolicTraits.contains(.traitItalic) {
            traitsToApply.insert(.traitItalic)
        }
        if let newFontDescriptor = targetFont.fontDescriptor.withSymbolicTraits(traitsToApply) {
            return .change([.font: UIFont(descriptor: newFontDescriptor, size: font.pointSize)])
        }
        return .change([.font: targetFont])
    }
}
