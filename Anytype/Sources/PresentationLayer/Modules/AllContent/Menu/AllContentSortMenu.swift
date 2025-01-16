import SwiftUI
import Services

struct AllContentSortMenu: View {
    @Binding var sort: ObjectSort
    
    var body: some View {
        ObjectsSortMenu(
            sort: $sort,
            label: {
                AnytypeText(Loc.AllContent.Settings.Sort.title, style: .uxTitle2Medium)
                    .foregroundColor(.Control.button)
                Text(sort.relation.title)
            }
        )
        .menuActionDisableDismissBehavior()
    }
}
