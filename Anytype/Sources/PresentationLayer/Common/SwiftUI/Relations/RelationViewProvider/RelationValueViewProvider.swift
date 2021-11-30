import SwiftUI

struct RelationValueViewProvider {

    static func relationView(_ relation: Relation, style: RelationStyle) -> some View {
        Group {
            let value = relation.value
            let hint = relation.hint

            switch value {
            case .text(let string):
                TextRelationView(value: string, hint: hint, style: style, allowMultiLine: style.allowMultiLine)
            case .number(let string):
                TextRelationView(value: string, hint: hint, style: style)
            case .status(let statusRelation):
                StatusRelationView(value: statusRelation, hint: hint, style: style)
            case .date(let value):
                TextRelationView(value: value?.text, hint: hint, style: style)
            case .object(let objectsRelation):
                ObjectRelationView(value: objectsRelation, hint: hint, style: style)
            case .checkbox(let bool):
                CheckboxRelationView(isChecked: bool)
            case .url(let string):
                TextRelationView(value: string, hint: hint, style: style)
            case .email(let string):
                TextRelationView(value: string, hint: hint, style: style)
            case .phone(let string):
                TextRelationView(value: string, hint: hint, style: style)
            case .tag(let tags):
                TagRelationView(value: tags, hint: hint, style: style)
            case .unknown(let string):
                RelationsListRowHintView(hint: string)
            }
        }
    }
}
