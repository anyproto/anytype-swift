import AnytypeCore
import BlocksModels
import ProtobufMessages

/// Entity to create BlockInformation from middle events
struct BlockInformationCreator {
    
    private let validator: BlockValidator
    private let container: RootBlockContainer
    
    init(
        validator: BlockValidator,
        container: RootBlockContainer
    ) {
        self.validator = validator
        self.container = container
    }
    
    func createBlockInformation(from newData: Anytype_Event.Block.Set.Text) -> BlockInformation? {
        guard let blockModel = container.blocksContainer.model(id: newData.id) else {
            anytypeAssertionFailure("Block model with id \(newData.id) not found in container")
            return nil
        }
        guard case let .text(oldText) = blockModel.information.content else {
            anytypeAssertionFailure("Block model doesn't support text:\n \(blockModel.information)")
            return nil
        }

        let color = newData.hasColor ? newData.color.value : oldText.color?.rawValue
        let text = newData.hasText ? newData.text.value : oldText.attributedText.clearedFromMentionAtachmentsString()
        let checked = newData.hasChecked ? newData.checked.value : oldText.checked
        let style = newData.hasStyle ? newData.style.value : BlockTextContentTypeConverter.asMiddleware(oldText.contentType)
        let marks = buildMarks(newData: newData, oldText: oldText)
        
        let middleContent = Anytype_Model_Block.Content.Text(
            text: text,
            style: style,
            marks: marks,
            checked: checked,
            color: color ?? ""
        )
        
        guard var textContent = ContentTextConverter().textContent(middleContent) else {
            anytypeAssertionFailure("We cannot block content from: \(middleContent)")
            return nil
        }

        if !newData.hasStyle {
            textContent.contentType = oldText.contentType
        }
        textContent.number = oldText.number
        
        var information = blockModel.information
        information.content = .text(textContent)
        return validator.validated(information: information)
    }
    
    func createBlockInformation(newAlignmentData: Anytype_Event.Block.Set.Align) -> BlockInformation? {
        guard let blockModel = container.blocksContainer.model(id: newAlignmentData.id) else {
            anytypeAssertionFailure("Block model with id \(newAlignmentData.id) not found in container")
            return nil
        }
        guard let alignment = newAlignmentData.align.asBlockModel else { return nil }
        return blockModel.information.updated(with: alignment)
    }
    
    private func buildMarks(newData: Anytype_Event.Block.Set.Text, oldText: BlockText) -> Anytype_Model_Block.Content.Text.Marks {
        typealias TextConverter = MiddlewareModelsModule.Parsers.Text.AttributedText.Converter
        
        let useNewMarks = newData.marks.hasValue
        var marks = useNewMarks ? newData.marks.value : TextConverter.asMiddleware(attributedText: oldText.attributedText).marks
        
        // Workaroung: Some font could set bold style to attributed string
        // So if header or title style has font that apply bold we remove it
        // We need it if change style from subheading to text
        let oldStyle = BlockTextContentTypeConverter.asMiddleware(oldText.contentType)
        if [.header1, .header2, .header3, .header4, .title].contains(oldStyle) {
            marks.marks.removeAll { mark in
                mark.type == .bold
            }
        }
        
        return marks
    }
}
