
import BlocksModels

struct BlockValidator {
    
    private let restrictionsFactory: BlockRestrictionsFactory
    
    init(restrictionsFactory: BlockRestrictionsFactory) {
        self.restrictionsFactory = restrictionsFactory
    }
    
    func validate(information: inout BlockInformation.InformationModel) {
        let restrictions = self.restrictionsFactory.makeRestrictions(for: information.content)
        if case let .text(text) = information.content {
            information.content = .text(self.validatedTextContent(content: text,
                                                                           restrictions: restrictions))
        }
        if !restrictions.canApplyBackgroundColor {
            information.backgroundColor = ""
        }
        if !restrictions.availableAlignments.contains(information.alignment) {
            information.alignment = restrictions.availableAlignments.first ?? .left
        }
    }
    
    func validatedTextContent(content: BlockContent.Text, restrictions: BlockRestrictions) -> BlockContent.Text {
        let marks = MiddlewareModelsModule.Parsers.Text.AttributedText.Converter.asMiddleware(attributedText: content.attributedText).marks.marks
        let filteredMarks = marks.filter {
            switch $0.type {
            case .strikethrough, .keyboard, .italic, .underscored, .link:
                return restrictions.canApplyOtherMarkup
            case .bold:
                return restrictions.canApplyBold
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
        let style = BlocksModelsParserTextContentTypeConverter.asMiddleware(content.contentType)
        let attributedString = MiddlewareModelsModule.Parsers.Text.AttributedText.Converter.asModel(text: content.attributedText.string,
                                                                                                    marks: .init(marks: filteredMarks),
                                                                                                    style: style)
        return BlockContent.Text(attributedText: attributedString,
                                 color: content.color,
                                 contentType: content.contentType,
                                 checked: content.checked,
                                 number: content.number)
    }
}
