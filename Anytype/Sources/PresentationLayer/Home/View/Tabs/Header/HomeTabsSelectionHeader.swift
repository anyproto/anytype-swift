import SwiftUI

struct HomeTabsSelectionHeader: View {
    @EnvironmentObject var model: HomeViewModel
    
    var body: some View {
        HStack(spacing: 0) {
            Button(
                action: {
                    model.selectAll(!model.isAllSelected)
                    UISelectionFeedbackGenerator().selectionChanged()
                }, label: {
                    AnytypeText(
                        model.isAllSelected ? Loc.deselectAll : Loc.selectAll,
                        style: .uxBodyRegular,
                        color: .textPrimary
                    )
                }
            )
            Spacer()
            
            AnytypeText(Loc.objectSelected(model.numberOfSelectedPages), style: .uxTitle1Semibold, color: .textPrimary)
            Spacer()
            Button(
                action: {
                    model.selectAll(false)
                    UISelectionFeedbackGenerator().selectionChanged()
                }, label: {
                    AnytypeText(Loc.cancel, style: .uxBodyRegular, color: .textPrimary)
                }
            )
        }
    }
}
