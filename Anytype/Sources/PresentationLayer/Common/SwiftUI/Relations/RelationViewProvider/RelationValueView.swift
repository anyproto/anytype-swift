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
                TextRelationFactory.swiftUI(value: text.value, hint: relation.hint, style: style)
            case .number(let text):
                TextRelationFactory.swiftUI(value: text.value, hint: relation.hint, style: style)
            case .status(let status):
                StatusRelationView(statusOption: status.value, hint: relation.hint, style: style)
            case .date(let date):
                TextRelationFactory.swiftUI(value: date.value?.text, hint: relation.hint, style: style)
            case .object(let object):
                ObjectRelationView(options: object.selectedObjects, hint: relation.hint, style: style)
            case .checkbox(let checkbox):
                CheckboxRelationView(isChecked: checkbox.value)
            case .url(let text):
                TextRelationFactory.swiftUI(value: text.value, hint: relation.hint, style: style)
            case .email(let text):
                TextRelationFactory.swiftUI(value: text.value, hint: relation.hint, style: style)
            case .phone(let text):
                TextRelationFactory.swiftUI(value: text.value, hint: relation.hint, style: style)
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
