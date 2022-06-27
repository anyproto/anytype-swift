import SwiftUI

struct CheckboxRelationView: View {
    let isChecked: Bool
    let style: RelationStyle
    
    var body: some View {
        switch style {
        case .regular, .set:
            icon
        case .featuredRelationBlock:
            featuredRelationBlockIcon
        case .filter:
            filterText
        }
    }
    
    private var featuredRelationBlockIcon: some View {
        Group {
            isChecked ? Image.Relations.checkboxChecked.resizable() : Image.Relations.checkboxUnchecked.resizable()
        }.frame(width: style.checkboxSize.width, height: style.checkboxSize.height)
        
    }
    
    private var icon: some View {
        Group {
            isChecked ? Image.Relations.checkboxChecked : Image.Relations.checkboxUnchecked
        }
    }
    
    private var filterText: some View {
        Group {
            AnytypeText(
                isChecked ? "EditSorts.Popup.Filter.Value.Checked".localized :
                    "EditSorts.Popup.Filter.Value.Unchecked".localized,
                style: .relation1Regular,
                color: .textSecondary
            )
        }
    }
}

struct CheckboxRelationView_Previews: PreviewProvider {
    static var previews: some View {
        CheckboxRelationView(isChecked: true, style: .featuredRelationBlock(allowMultiLine: false))
    }
}
