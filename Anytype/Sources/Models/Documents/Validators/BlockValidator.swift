
import BlocksModels

struct BlockValidator {
    
    private let restrictionsFactory: BlockRestrictionsFactory
    
    init(restrictionsFactory: BlockRestrictionsFactory) {
        self.restrictionsFactory = restrictionsFactory
    }
    
    func validated(information info: BlockInformation) -> BlockInformation {
        let restrictions = restrictionsFactory.makeRestrictions(for: info.content)
        
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
        let alignment = validatedAlignment(alignment: info.alignment, restrictions: restrictions)
        
        return BlockInformation(
            id: info.id,
            content: content,
            backgroundColor: backgroundColor,
            alignment: alignment,
            childrenIds: info.childrenIds,
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
        let marks = AttributedTextConverter.asMiddleware(attributedText: content.attributedText).marks.marks
        let filteredMarks = marks.filter { mark in
            switch mark.type {
            case .strikethrough, .keyboard, .underscored, .link:
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
            case .UNRECOGNIZED:
                return false
            }
        }
        let style = BlockTextContentTypeConverter.asMiddleware(content.contentType)
        let attributedString = AttributedTextConverter.asModel(
            text: content.attributedText.clearedFromMentionAtachmentsString(),
            marks: .init(marks: filteredMarks),
            style: style
        )
        
        return BlockText(
            attributedText: attributedString,
            color: content.color,
            contentType: content.contentType,
            checked: content.checked,
            number: content.number
        )
    }
}
