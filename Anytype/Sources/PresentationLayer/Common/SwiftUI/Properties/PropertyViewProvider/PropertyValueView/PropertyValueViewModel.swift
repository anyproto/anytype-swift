import SwiftUI

struct PropertyValueViewModel {
    let property: PropertyItemModel?
    let style: PropertyStyle
    let mode: Mode
    let leftAlign: Bool
    
    init(
        property: PropertyItemModel? = nil,
        style: PropertyStyle = .regular(allowMultiLine: false),
        mode: Mode = .button(action: nil),
        leftAlign: Bool = false
    ) {
        self.property = property
        self.style = style
        self.mode = mode
        self.leftAlign = leftAlign
    }
    
    func hint(for style: PropertyStyle, property: PropertyItemModel) -> String {
        switch style {
        case .regular, .set, .setCollection, .filter, .kanbanHeader:
            return property.hint
        case .featuredBlock:
            let maxLenght = TextPropertyFactory.maxLength(style: style)
            return TextPropertyFactory.text(value: property.name, maxLength: maxLenght) ?? property.name
        }
    }
}

extension PropertyValueViewModel {
    enum Mode {
        case button(action: (() -> Void)?)
        case contextMenu([MenuItem])
    }
    
    struct MenuItem {
        let title: String
        let action: () -> Void
    }
}
