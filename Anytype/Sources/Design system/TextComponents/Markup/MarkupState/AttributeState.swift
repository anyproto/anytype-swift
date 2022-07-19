import UIKit
import BlocksModels

enum AttributeState {
    case disabled
    case applied
    case notApplied

    static func state(
        markup: MarkupType,
        in range: NSRange,
        string: NSAttributedString,
        with restrictions: BlockRestrictions) -> AttributeState
    {
        guard restrictions.isMarkupAvailable(markup) else { return .disabled }
        guard string.hasMarkup(markup, range: range) else { return .notApplied }
        return .applied
    }

    static func allMarkupAttributesState(
        in range: NSRange,
        string: NSAttributedString,
        with restrictions: BlockRestrictions
    ) -> [MarkupType: AttributeState] {
        var allAttributesState = [MarkupType: AttributeState]()

        MarkupType.allCases.forEach {
            allAttributesState[$0] = AttributeState.state(markup: $0, in: range, string: string, with: restrictions)
        }

        return allAttributesState
    }

    static func markupAttributes(from blocks: [BlockInformation]) -> [MarkupType: AttributeState] {
        let blocksMarkupAttributes = blocks.compactMap { blockInformation -> [MarkupType: AttributeState]? in
            guard case let .text(textBlock) = blockInformation.content else { return nil }
            let anytypeText = AttributedTextConverter.asModel(
                text: textBlock.text,
                marks: textBlock.marks,
                style: textBlock.contentType
            )

            let restrictions = BlockRestrictionsBuilder.build(textContentType: textBlock.contentType)

            return AttributeState.allMarkupAttributesState(
                in: anytypeText.attrString.wholeRange,
                string: anytypeText.attrString,
                with: restrictions
            )
        }

        var mergedMarkupAttributes = [MarkupType: AttributeState]()
        blocksMarkupAttributes.forEach { markups in
            markups.forEach { markupKey, value in
                if let existingValue = mergedMarkupAttributes[markupKey] {
                    switch existingValue {
                    case .applied:
                        mergedMarkupAttributes[markupKey] = value
                    case .disabled:
                        mergedMarkupAttributes[markupKey] = .disabled
                    case .notApplied:
                        if case .applied = value {
                            return
                        }

                        mergedMarkupAttributes[markupKey] = value
                    }
                } else {
                    mergedMarkupAttributes[markupKey] = value
                }
            }
        }

        return mergedMarkupAttributes
    }

    static func alignmentAttributes(from blocks: [BlockInformation]) -> [LayoutAlignment: AttributeState] {
        var alignmentsStates = [LayoutAlignment: AttributeState]()

        blocks.forEach { blockInformation in
            guard case let .text(textBlock) = blockInformation.content else { return }

            let restrictions = BlockRestrictionsBuilder.build(textContentType: textBlock.contentType)

            LayoutAlignment.allCases.forEach {
                guard restrictions.isAlignmentAvailable($0) else {
                    alignmentsStates[$0] = .disabled
                    return
                }

                if alignmentsStates[$0] == .notApplied {
                    return
                } else {
                    alignmentsStates[$0] = blockInformation.horizontalAlignment == $0 ? .applied : .notApplied
                }
            }
        }

        return alignmentsStates
    }
}
