import SwiftUI
import AnytypeCore

struct RelationValueView: View {
    let relation: Relation
    let style: RelationStyle
    let action: ((_ relation: Relation) -> Void)?

    var body: some View {
        if action.isNotNil && relation.isEditable {
            Button {
                action?(relation)
            } label: {
                relationView
            }
        } else {
            relationView
        }
    }

    private var relationView: some View {
        HStack(spacing: 0) {
            switch relation {
            case .text(let text):
                TextRelationView(value: text.value, hint: relation.hint, style: style, allowMultiLine: style.allowMultiLine).swiftUI
            case .number(let text):
                TextRelationView(value: text.value, hint: relation.hint, style: style).swiftUI
            case .status(let status):
                StatusRelationView(statusOption: status.value, hint: relation.hint, style: style)
            case .date(let date):
                TextRelationView(value: date.value?.text, hint: relation.hint, style: style).swiftUI
            case .object(let object):
                ObjectRelationView(options: object.selectedObjects, hint: relation.hint, style: style)
            case .checkbox(let checkbox):
                CheckboxRelationView(isChecked: checkbox.value)
            case .url(let text):
                TextRelationView(value: text.value, hint: relation.hint, style: style).swiftUI
            case .email(let text):
                TextRelationView(value: text.value, hint: relation.hint, style: style).swiftUI
            case .phone(let text):
                TextRelationView(value: text.value, hint: relation.hint, style: style).swiftUI
            case .tag(let tag):
                TagRelationView(tags: tag.selectedTags, hint: relation.hint, style: style)
            case .file(let file):
                FileRelationView(options: file.files, hint: relation.hint, style: style)
            case .unknown(let unknown):
                RelationsListRowPlaceholderView(hint: unknown.value, type: style.placeholderType)
            }
            Spacer()
        }
    }
}
