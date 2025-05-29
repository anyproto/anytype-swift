import SwiftUI

struct PropertyListSelectionView: View {
    let selectionMode: PropertySelectionOptionsMode
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
    PropertyListSelectionView(
        selectionMode: .single,
        selectedIndex: 1
    )
}

#Preview("RelationListMultiSelection") {
    PropertyListSelectionView(
        selectionMode: .multi,
        selectedIndex: 3
    )
}
