import SwiftUI
import SwiftUIVisualEffects

struct DashboardSelectionActionsView: View {
    static let height: CGFloat = 48
    @EnvironmentObject private var model: HomeViewModel
    
    var body: some View {
        Group {
            if model.isSelectionMode {
                VStack(spacing: 0) {
                    Spacer()
                    view
                }
            } else {
                EmptyView()
            }
        }
    }
    
    private var view: some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(12)
            buttons
            Spacer.fixedHeight(UIApplication.shared.mainWindowInsets.bottom + 12)
        }
        .frame(height: Self.height + UIApplication.shared.mainWindowInsets.bottom)
        .background(BlurEffect())
    }
    
    private var buttons: some View {
        HStack(alignment: .center, spacing: 0) {
            Button(action: {
                UISelectionFeedbackGenerator().selectionChanged()
                model.deleteSelected()
            }, label: {
                AnytypeText(Loc.delete, style: .uxBodyRegular, color: .TextNew.primary)
            })
                .frame(maxWidth: .infinity)
            
            Button(action: {
                UISelectionFeedbackGenerator().selectionChanged()
                model.restoreSelected()
            }, label: {
                AnytypeText(Loc.restore, style: .uxBodyRegular, color: .TextNew.primary)
            })
                .frame(maxWidth: .infinity)
        }
    }
}
