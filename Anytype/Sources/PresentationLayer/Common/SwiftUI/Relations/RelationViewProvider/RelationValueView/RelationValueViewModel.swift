import SwiftUI

struct RelationValueViewModel {
    let relation: RelationItemModel?
    let style: RelationStyle
    let mode: Mode
    let leftAlign: Bool
    
    init(
        relation: RelationItemModel? = nil,
        style: RelationStyle = .regular(allowMultiLine: false),
        mode: Mode = .button(action: nil),
        leftAlign: Bool = false
    ) {
        self.relation = relation
        self.style = style
        self.mode = mode
        self.leftAlign = leftAlign
    }
    
    func hint(for style: RelationStyle, relation: RelationItemModel) -> String {
        switch style {
        case .regular, .set, .setCollection, .filter, .kanbanHeader:
            return relation.hint
        case .featuredRelationBlock:
            let maxLenght = TextRelationFactory.maxLength(style: style)
            return TextRelationFactory.text(value: relation.name, maxLength: maxLenght) ?? relation.name
        }
    }
}

extension RelationValueViewModel {
    enum Mode {
        case button(action: (() -> Void)?)
        case contextMenu([MenuItem])
    }
    
    struct MenuItem {
        let title: String
        let action: () -> Void
    }
}
