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
                ObjectRelationView(value: object.value, hint: relation.hint, style: style)
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
            case .unknown(let unknown):
                RelationsListRowPlaceholderView(hint: unknown.value, type: style.placeholderType)
            }
            
//            let value = relation.value
//            let hint = relation.hint
//
//            switch value {
//            case .text(let string):
//                TextRelationView(value: string, hint: hint, style: style, allowMultiLine: style.allowMultiLine)
//            case .number(let string):
//                TextRelationView(value: string, hint: hint, style: style)
//            case .status(let statusRelation):
//                StatusRelationView(value: statusRelation, hint: hint, style: style)
//            case .date(let value):
//                TextRelationView(value: value?.text, hint: hint, style: style)
//            case .object(let objectsRelation):
//                ObjectRelationView(value: objectsRelation, hint: hint, style: style)
//            case .checkbox(let bool):
//                CheckboxRelationView(isChecked: bool)
//            case .url(let string):
//                TextRelationView(value: string, hint: hint, style: style)
//            case .email(let string):
//                TextRelationView(value: string, hint: hint, style: style)
//            case .phone(let string):
//                TextRelationView(value: string, hint: hint, style: style)
//            case .tag(let tags):
//                TagRelationView(value: tags, hint: hint, style: style)
//            case .unknown(let string):
//                RelationsListRowPlaceholderView(hint: string, type: style.placeholderType)
//            }
        }
    }
}
