import SwiftUI

struct CheckboxRelationView: View {
    let name: String
    let isChecked: Bool
    let style: RelationStyle
    
    var body: some View {
        switch style {
        case .regular, .set:
            icon
        case .featuredRelationBlock, .kanbanHeader, .setCollection:
            featuredRelationBlock
        case .filter:
            filterText
        }
    }
    
    private var featuredRelationBlock: some View {
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
                    .foregroundColor(.Control.active)
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
                .foregroundColor(.Control.active)
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
        CheckboxRelationView(
            name: "Checkbox",
            isChecked: true,
            style: .featuredRelationBlock(FeaturedRelationSettings(allowMultiLine: false))
        )
    }
}
