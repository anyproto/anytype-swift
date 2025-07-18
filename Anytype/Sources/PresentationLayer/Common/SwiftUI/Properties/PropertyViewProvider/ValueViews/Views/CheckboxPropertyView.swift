import SwiftUI

struct CheckboxPropertyView: View {
    let name: String
    let isChecked: Bool
    let style: PropertyStyle
    
    var body: some View {
        switch style {
        case .regular, .set:
            icon
        case .featuredBlock, .kanbanHeader, .setCollection:
            featuredBlock
        case .filter:
            filterText
        }
    }
    
    private var featuredBlock: some View {
        HStack(spacing: 6) {
            featuredRelationBlockIcon
            AnytypeText(name, style: style.font)
                .foregroundStyle(isChecked ? style.fontColor : style.hintColor)
                .multilineTextAlignment(.leading)
                .lineLimit(style.allowMultiLine ? nil : 1)
        }
    }
    
    private var featuredRelationBlockIcon: some View {
        Group {
            if isChecked {
                Image(asset: .relationCheckboxChecked)
                    .resizable()
            } else {
                Image(asset: .relationCheckboxUnchecked)
                    .resizable()
                    .foregroundColor(.Control.secondary)
            }
        }
        .frame(width: style.checkboxSize.width, height: style.checkboxSize.height)
    }
    
    @ViewBuilder
    private var icon: some View {
        if isChecked {
            Image(asset: .relationCheckboxChecked)
        } else {
            Image(asset: .relationCheckboxUnchecked)
                .foregroundColor(.Control.secondary)
        }
    }
    
    private var filterText: some View {
        let text = isChecked ? Loc.EditSet.Popup.Filter.Value.checked :
        Loc.EditSet.Popup.Filter.Value.unchecked
        return AnytypeText(
            text.lowercased(),
            style: .relation1Regular
        )
        .foregroundColor(.Text.secondary)
    }
}

struct CheckboxRelationView_Previews: PreviewProvider {
    static var previews: some View {
        CheckboxPropertyView(
            name: "Checkbox",
            isChecked: true,
            style: .featuredBlock(FeaturedPropertySettings(allowMultiLine: false))
        )
    }
}
