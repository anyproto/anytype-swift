import SwiftUI
import AnytypeCore

struct RelationValueView: View {
    let relation: RelationItemModel
    let style: RelationStyle
    let mode: Mode

    var body: some View {
        switch mode {
        case .button(let action):
            buttonView(with: action)
        case .contextMenu(let items):
            contextMenuView(from: items)
        }
    }
    
    @ViewBuilder
    private func buttonView(with action: (() -> Void)?) -> some View {
        if action.isNotNil && relation.isEditable {
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
    private func contextMenuView(from items: [MenuItem]) -> some View {
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

    private var relationView: some View {
        HStack(spacing: 0) {
            switch relation {
            case .text(let text):
                TextRelationFactory.swiftUI(value: text.value, hint: relation.hint, style: style)
            case .number(let text):
                TextRelationFactory.swiftUI(value: text.value, hint: relation.hint, style: style)
            case .status(let status):
                StatusRelationView(options: status.values, hint: relation.hint, style: style)
            case .date(let date):
                TextRelationFactory.swiftUI(value: date.value?.text, hint: relation.hint, style: style)
            case .object(let object):
                ObjectRelationView(options: object.selectedObjects, hint: relation.hint, style: style)
            case .checkbox(let checkbox):
                CheckboxRelationView(isChecked: checkbox.value, style: style)
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
                RelationsListRowPlaceholderView(hint: unknown.value, style: style)
            }
            Spacer()
        }
    }
}

extension RelationValueView {
    enum Mode {
        case button(action: (() -> Void)?)
        case contextMenu([MenuItem])
    }
    
    struct MenuItem {
        let title: String
        let action: () -> Void
    }
}
