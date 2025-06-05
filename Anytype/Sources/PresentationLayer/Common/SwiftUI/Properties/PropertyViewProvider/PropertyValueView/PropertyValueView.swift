import SwiftUI
import AnytypeCore

struct PropertyValueView: View {
    let model: PropertyValueViewModel

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
                propertyView
            }
        } else {
            propertyView
        }
    }
    
    @ViewBuilder
    private func contextMenuView(from items: [PropertyValueViewModel.MenuItem]) -> some View {
        if items.isNotEmpty {
            Menu {
                ForEach(items, id: \.title) { item in
                    Button(item.title) {
                        item.action()
                    }
                }
            } label: {
                propertyView
            }
        } else {
            propertyView
        }
    }

    @ViewBuilder
    private var propertyView: some View {
        if let property = model.property {
            propertyView(for: property, style: model.style)
        }
    }
    
    @ViewBuilder
    private func propertyView(for property: PropertyItemModel, style: PropertyStyle) -> some View {
        let hint = model.hint(for: style, property: property)
        HStack(spacing: 0) {
            switch property {
            case .text(let text):
                TextPropertyFactory.view(value: text.value, hint: hint, style: style)
            case .number(let text):
                TextPropertyFactory.view(value: text.value, hint: hint, style: style)
            case .status(let status):
                StatusPropertyView(options: status.values, hint: hint, style: style)
            case .date(let date):
                TextPropertyFactory.view(value: date.value?.text, hint: hint, style: style)
            case .object(let object):
                ObjectPropertyView(options: object.selectedObjects, hint: hint, style: style)
            case .checkbox(let checkbox):
                CheckboxPropertyView(name: checkbox.name, isChecked: checkbox.value, style: style)
            case .url(let text):
                TextPropertyFactory.view(value: text.value, hint: hint, style: style)
            case .email(let text):
                TextPropertyFactory.view(value: text.value, hint: hint, style: style)
            case .phone(let text):
                TextPropertyFactory.view(value: text.value, hint: hint, style: style)
            case .tag(let tag):
                TagPropertyView(tags: tag.selectedTags, hint: hint, style: style)
            case .file(let file):
                FilePropertyView(options: file.files, hint: hint, style: style)
            case .unknown:
                PropertyValuePlaceholderView(hint: hint, style: style)
            }
        }
        .if(model.leftAlign, transform: {
            $0.frame(maxWidth: .infinity, alignment: .leading)
        })
    }
}