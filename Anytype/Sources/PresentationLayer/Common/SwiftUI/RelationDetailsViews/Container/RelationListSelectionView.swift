import SwiftUI

struct RelationListSelectionView: View {
    let selectionMode: RelationSelectionOptionsMode
    let selectedIndex: Int?
    
    var body: some View {
        switch selectionMode {
        case .single:
            if selectedIndex.isNotNil {
                Image(asset: .relationCheckboxChecked)
            }
        case .multi:
            if let selectedIndex {
                SelectionIndicatorView(model: .selected(index: selectedIndex + 1))
            } else {
                SelectionIndicatorView(model: .notSelected)
            }
        }
    }
}

#Preview("RelationListSingleSelection") {
    RelationListSelectionView(
        selectionMode: .single,
        selectedIndex: 1
    )
}

#Preview("RelationListMultiSelection") {
    RelationListSelectionView(
        selectionMode: .multi,
        selectedIndex: 3
    )
}
