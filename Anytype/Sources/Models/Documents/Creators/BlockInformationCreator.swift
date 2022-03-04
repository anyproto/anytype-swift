import AnytypeCore
import BlocksModels
import ProtobufMessages

/// Entity to create BlockInformation from middle events
struct BlockInformationCreator {
    
    private let validator: BlockValidator
    private let blocksContainer: InfoContainerProtocol
    
    init(
        validator: BlockValidator,
        blocksContainer: InfoContainerProtocol
    ) {
        self.validator = validator
        self.blocksContainer = blocksContainer
    }
    
    func createBlockInformation(from newData: Anytype_Event.Block.Set.Text) -> BlockInformation? {
        guard let info = blocksContainer.get(id: newData.id) else {
            anytypeAssertionFailure(
                "Block model with id \(newData.id) not found in container",
                domain: .blockInformationCreator
            )
            return nil
        }
        guard case let .text(oldText) = info.content else {
            anytypeAssertionFailure(
                "Block model doesn't support text:\n \(info)",
                domain: .blockInformationCreator
            )
            return nil
        }

        let color = newData.hasColor ? newData.color.value : oldText.color?.rawValue
        let text = newData.hasText ? newData.text.value : oldText.text
        let checked = newData.hasChecked ? newData.checked.value : oldText.checked
        let style = newData.hasStyle ? newData.style.value : oldText.contentType.asMiddleware
        let marks = buildMarks(newData: newData, oldText: oldText)
        let iconEmoji = newData.hasIconEmoji ? newData.iconEmoji.value : oldText.iconEmoji
        let iconImage = newData.hasIconImage ? newData.iconImage.value : oldText.iconImage
        
        let middleContent = Anytype_Model_Block.Content.Text(
            text: text,
            style: style,
            marks: marks,
            checked: checked,
            color: color ?? "",
            iconEmoji: iconEmoji,
            iconImage: iconImage
        )
        
        guard var textContent = middleContent.textContent else {
            anytypeAssertionFailure("We cannot block content from: \(middleContent)", domain: .blockInformationCreator)
            return nil
        }

        if !newData.hasStyle {
            textContent.contentType = oldText.contentType
        }
        textContent.number = oldText.number
        
        var newInfo = info
        newInfo.content = .text(textContent)
        return validator.validated(information: newInfo)
    }
    
    func createBlockInformation(newAlignmentData: Anytype_Event.Block.Set.Align) -> BlockInformation? {
        guard let info = blocksContainer.get(id: newAlignmentData.id) else {
            anytypeAssertionFailure(
                "Block model with id \(newAlignmentData.id) not found in container",
                domain: .blockInformationCreator
            )
            return nil
        }
        guard let alignment = newAlignmentData.align.asBlockModel else { return nil }
        return info.updated(with: alignment)
    }
    
    private func buildMarks(
        newData: Anytype_Event.Block.Set.Text,
        oldText: BlockText
    ) -> Anytype_Model_Block.Content.Text.Marks {
        let useNewMarks = newData.marks.hasValue
        var marks: Anytype_Model_Block.Content.Text.Marks = useNewMarks ? newData.marks.value : oldText.marks
        
        // Workaroung: Some font could set bold style to attributed string
        // So if header or title style has font that apply bold we remove it
        // We need it if change style from subheading to text
        let oldStyle = oldText.contentType.asMiddleware
        if [.header1, .header2, .header3, .header4, .title].contains(oldStyle) {
            marks.marks.removeAll { mark in
                mark.type == .bold
            }
        }
        
        return marks
    }
}
