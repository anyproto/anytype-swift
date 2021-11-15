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
}
