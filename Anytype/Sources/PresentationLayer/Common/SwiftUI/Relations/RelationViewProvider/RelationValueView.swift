import SwiftUI

struct RelationValueView: View {
    let relation: Relation
    let style: RelationStyle
    
    var body: some View {
        Group {
            switch relation {
            case .text(let text):
                TextRelationView(value: text.value, hint: relation.hint, style: style, allowMultiLine: style.allowMultiLine)
            case .number(let text):
                TextRelationView(value: text.value, hint: relation.hint, style: style)
            case .status(let status):
                StatusRelationView(statusOption: status.value, hint: relation.hint, style: style)
            case .date(let date):
                TextRelationView(value: date.value?.text, hint: relation.hint, style: style)
            case .object(let object):
                ObjectRelationView(options: object.selectedObjects, hint: relation.hint, style: style)
            case .checkbox(let checkbox):
                CheckboxRelationView(isChecked: checkbox.value)
            case .url(let text):
                TextRelationView(value: text.value, hint: relation.hint, style: style)
            case .email(let text):
                TextRelationView(value: text.value, hint: relation.hint, style: style)
            case .phone(let text):
                TextRelationView(value: text.value, hint: relation.hint, style: style)
            case .tag(let tag):
                TagRelationView(tags: tag.selectedTags, hint: relation.hint, style: style)
            case .file(let file):
                EmptyView()
            case .unknown(let unknown):
                RelationsListRowPlaceholderView(hint: unknown.value, type: style.placeholderType)
            }
        }
    }
}
