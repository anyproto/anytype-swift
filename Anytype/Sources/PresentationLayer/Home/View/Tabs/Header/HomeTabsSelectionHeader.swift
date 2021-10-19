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
                        model.isAllSelected ? "Deselect all".localized : "Select all".localized,
                        style: .uxBodyRegular,
                        color: .textPrimary
                    )
                }
            )
            Spacer()
            AnytypeText("\(model.numberOfSelectedPages) \(objectsLiteral) selected", style: .uxTitle1Semibold, color: .textPrimary)
            Spacer()
            Button(
                action: {
                    model.selectAll(false)
                    UISelectionFeedbackGenerator().selectionChanged()
                }, label: {
                    AnytypeText("Cancel", style: .uxBodyRegular, color: .textPrimary)
                }
            )
        }
    }
    
    var objectsLiteral: String {
        model.numberOfSelectedPages == 1 ? "object" : "objects"
    }
}
