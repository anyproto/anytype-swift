import AnytypeCore
import Services

struct BlockValidator {    
    func validated(information info: BlockInformation) -> BlockInformation {
        let restrictions = BlockRestrictionsBuilder.build(content: info.content)
        
        let content: BlockContent
        if case let .text(text) = info.content {
            content = .text(
                validatedTextContent(
                    content: text,       
                    restrictions: restrictions
                )
            )
        } else {
            content = info.content
        }
        
        let backgroundColor = restrictions.canApplyBackgroundColor ? info.backgroundColor : nil
        let horizontalAlignment = validatedAlignment(alignment: info.horizontalAlignment, restrictions: restrictions)
        
        return BlockInformation(
            id: info.id,
            content: content,
            backgroundColor: backgroundColor,
            horizontalAlignment: horizontalAlignment,
            childrenIds: info.childrenIds,
            configurationData: info.configurationData,
            fields: info.fields
        )
    }
    
    func validatedAlignment(alignment: LayoutAlignment, restrictions: BlockRestrictions) -> LayoutAlignment {
        guard !restrictions.availableAlignments.contains(alignment) else {
            return alignment
        }
        
        return restrictions.availableAlignments.first ?? .left
    }
    
    func validatedTextContent(content: BlockText, restrictions: BlockRestrictions) -> BlockText {
        let filteredMarks = content.marks.marks.filter { mark in
            switch mark.type {
            case .strikethrough, .keyboard, .underscored, .link, .object:
                return restrictions.canApplyOtherMarkup
            case .bold:
                return restrictions.canApplyBold
            case .italic:
                return restrictions.canApplyItalic
            case .textColor:
                return restrictions.canApplyBlockColor
            case .backgroundColor:
                return restrictions.canApplyBackgroundColor
            case .mention:
                return restrictions.canApplyMention
            case .emoji:
                return restrictions.canApplyEmoji
            case .UNRECOGNIZED:
                anytypeAssertionFailure("Unsuppored mark \(mark)")
                return false
            }
        }
        
        return BlockText(
            text: content.text,
            marks: .with { $0.marks = filteredMarks },
            color: content.color,
            contentType: content.contentType,
            checked: content.checked,
            number: content.number,
            iconEmoji: content.iconEmoji,
            iconImage: content.iconImage
        )
    }
}
