import SwiftUI
import AnytypeCore

struct RelationValueView: View {
    let model: RelationValueViewModel

    var body: some View {
        switch model.mode {
        case .button(let action):
            buttonView(with: action)
        case .contextMenu(let items):
            contextMenuView(from: items)
        }
    }
    
    @ViewBuilder
    private func buttonView(with action: (() -> Void)?) -> some View {
        if action.isNotNil {
            Button {
                action?()
            } label: {
                relationView
            }
        } else {
            relationView
        }
    }
    
    @ViewBuilder
    private func contextMenuView(from items: [RelationValueViewModel.MenuItem]) -> some View {
        if items.isNotEmpty {
            Menu {
                ForEach(items, id: \.title) { item in
                    Button(item.title) {
                        item.action()
                    }
                }
            } label: {
                relationView
            }
        } else {
            relationView
        }
    }

    @ViewBuilder
    private var relationView: some View {
        if let relation = model.relation {
            relationView(for: relation, style: model.style)
        }
    }
    
    @ViewBuilder
    private func relationView(for relation: RelationItemModel, style: RelationStyle) -> some View {
        let hint = model.hint(for: style, relation: relation)
        HStack(spacing: 0) {
            switch relation {
            case .text(let text):
                TextRelationFactory.view(value: text.value, hint: hint, style: style)
            case .number(let text):
                TextRelationFactory.view(value: text.value, hint: hint, style: style)
            case .status(let status):
                StatusRelationView(options: status.values, hint: hint, style: style)
            case .date(let date):
                TextRelationFactory.view(value: date.value?.text, hint: hint, style: style)
            case .object(let object):
                ObjectRelationView(options: object.selectedObjects, hint: hint, style: style)
            case .checkbox(let checkbox):
                CheckboxRelationView(name: checkbox.name, isChecked: checkbox.value, style: style)
            case .url(let text):
                TextRelationFactory.view(value: text.value, hint: hint, style: style)
            case .email(let text):
                TextRelationFactory.view(value: text.value, hint: hint, style: style)
            case .phone(let text):
                TextRelationFactory.view(value: text.value, hint: hint, style: style)
            case .tag(let tag):
                TagRelationView(tags: tag.selectedTags, hint: hint, style: style)
            case .file(let file):
                FileRelationView(options: file.files, hint: hint, style: style)
            case .unknown:
                RelationValuePlaceholderView(hint: hint, style: style)
            }
        }
        .if(model.leftAlign, transform: {
            $0.frame(maxWidth: .infinity, alignment: .leading)
        })
    }
}
