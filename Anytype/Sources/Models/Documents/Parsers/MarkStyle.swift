import UIKit

enum MarkStyle: Equatable, CaseIterable {
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
    
    static var allCases: [MarkStyle] {
        return [
            .bold(false),
            .italic(false),
            .keyboard(false),
            .strikethrough(false),
            .underscored(false),
            .textColor(nil),
            .backgroundColor(nil),
            .link(nil),
            .mention(nil)
        ]
    }
    
    static var emptyCases: [MarkStyle] {
        allCases
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
    
    // MARK: Opposite
    func opposite() -> Self {
        switch self {
        case let .bold(value): return
            .bold(!value)
        case let .italic(value): return
            .italic(!value)
        case let .keyboard(value): return
            .keyboard(!value)
        case let .strikethrough(value): return
            .strikethrough(!value)
        case let .underscored(value): return
            .underscored(!value)
            
        case let .textColor(value): return
            .textColor(value) // or nil maybe?
        case let .backgroundColor(value): return
            .backgroundColor(value) // or nil maybe?
        case let .link(value): return
            .link(value) // or nil maybe?
        case let .mention(pageId):
            return .mention(pageId)
        }
    }
    
    // MARK: Conversion
    func from(attributes: [NSAttributedString.Key : Any]) -> Self {
        switch self {
        case .bold:
            guard let font = attributes[.font] as? UIFont,
                  font.fontDescriptor.symbolicTraits.contains(.traitBold) else { return .bold(false) }
            let traitsWithoutBold = font.fontDescriptor.symbolicTraits.subtracting(.traitBold)
            guard !font.fontDescriptor.withSymbolicTraits(traitsWithoutBold).isNil else {
                // This means that we can not create same font without bold traits
                // So bold is necessary attribute for this font
                return .bold(false)
            }
            return .bold( (attributes[.font] as? UIFont)?.fontDescriptor.symbolicTraits.contains(.traitBold) ?? false )
        case .italic: return .italic( (attributes[.font] as? UIFont)?.fontDescriptor.symbolicTraits.contains(.traitItalic) ?? false )
        case .keyboard:
            guard let font = attributes[.font] as? UIFont else { return .keyboard(false) }
            return .keyboard(font.isCode)
        case .strikethrough: return .strikethrough( (attributes[.strikethroughStyle] as? Int) == 1 )
        case .underscored: return .underscored( (attributes[.underlineStyle] as? Int) == 1 )
        case .textColor: return .textColor( attributes[.foregroundColor] as? UIColor )
        case .backgroundColor: return .backgroundColor(attributes[.backgroundColor] as? UIColor)
        case .link: return .link( attributes[.link] as? URL )
        case .mention:
            return .mention(attributes[.mention] as? String)
        }
    }
    
    // TODO: rethink.
    // Should we make option set here?
    static func from(attributes: [NSAttributedString.Key : Any]) -> [Self] {
        return allCases.map { $0.from(attributes: attributes) }
    }
    
    // CAUTION:
    // This method return ONLY SLIDES of correspoding attributes and can return empty dictionary.
    // Second value in a pair is keys to remove.
    func to(old: [NSAttributedString.Key : Any]) -> Update {
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
            return keyboardUpdate(with: old, hasStyle: hasStyle)
        case let .strikethrough(value): return .change([.strikethroughStyle : value ? 1 : 0])
        case let .underscored(value): return .change([ .underlineStyle : value ? 1 : 0 ])
        case let .textColor(value): return .change([ .foregroundColor : value as Any ])
        case let .backgroundColor(value): return .change([ .backgroundColor : value as Any ])
        case let .link(value): return .changeAndDeletedKeys([ .link : value as Any ], value.isNil ? [.link] : [])
        case let .mention(pageId): return .change([.mention: pageId as Any])
        }
    }
    
    private func keyboardUpdate(with attributes: [NSAttributedString.Key: Any], hasStyle: Bool) -> Update {
        guard let font = attributes[.font] as? UIFont else { return .change([:]) }
        return hasStyle ? .change([.font: UIFont.code(of: font.pointSize)]) : .change([.font: font])
    }
    
    
    /// A list version of a single `to(old:)` method.
    ///
    /// Consider, that you would like to apply a Sequence of styles to attributes.
    /// For that, you should perform some updates of these attributes.
    ///
    /// This method return a `List<Update>` which  should be applied to `old` attributes.
    ///
    /// Can be simplified as:
    ///
    /// f: old, style -> update
    /// f: old, styles -> [update]
    ///
    /// - Parameters:
    ///   - old: Attributes that we would like to change.
    ///   - styles: Styles that we would like to apply to attributes.
    /// - Returns: `List<Update>` that should be applied to attributes.
    ///
    static func to(old: [NSAttributedString.Key: Any], styles: [Self]) -> [Update] {
        styles.map({$0.to(old: old)})
    }
}
