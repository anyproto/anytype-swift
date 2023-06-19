import SwiftUI

struct CheckboxRelationView: View {
    let isChecked: Bool
    let style: RelationStyle
    
    var body: some View {
        switch style {
        case .regular, .set:
            icon
        case .featuredRelationBlock, .kanbanHeader:
            featuredRelationBlockIcon
        case .filter:
            filterText(lowercased: true)
        case .setCollection:
            filterText()
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
                    .foregroundColor(.Button.active)
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
                .foregroundColor(.Button.active)
        }
    }
    
    private func filterText(lowercased: Bool = false) -> some View {
        Group {
            let text = isChecked ? Loc.EditSet.Popup.Filter.Value.checked :
            Loc.EditSet.Popup.Filter.Value.unchecked
            AnytypeText(
                lowercased ? text.lowercased() : text,
                style: lowercased ? .relation1Regular : style.font,
                color: .Text.secondary
            )
        }
    }
}

struct CheckboxRelationView_Previews: PreviewProvider {
    static var previews: some View {
        CheckboxRelationView(
            isChecked: true,
            style: .featuredRelationBlock(FeaturedRelationSettings(allowMultiLine: false))
        )
    }
}
