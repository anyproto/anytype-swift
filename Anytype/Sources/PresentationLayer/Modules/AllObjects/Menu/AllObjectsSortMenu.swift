import SwiftUI
import Services

struct AllObjectsSortMenu: View {
    @Binding var sort: ObjectSort
    
    var body: some View {
        ObjectsSortMenu(
            sort: $sort,
            label: {
                AnytypeText(Loc.AllObjects.Settings.Sort.title, style: .uxTitle2Medium)
                    .foregroundColor(.Control.primary)
                Text(sort.relation.title)
            }
        )
        .menuActionDisableDismissBehavior()
    }
}
