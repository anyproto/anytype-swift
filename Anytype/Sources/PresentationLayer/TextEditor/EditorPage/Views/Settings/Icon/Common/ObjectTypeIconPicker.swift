import SwiftUI
import Services


struct ObjectTypeIconPicker: View {
    
    let isRemoveButtonAvailable: Bool
    let onIconSelect: (_ icon: CustomIcon, _ color: CustomIconColor) -> Void
    let removeIcon: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        content
            .ignoresSafeArea(.keyboard)
            .background(Color.Background.primary)
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            DragIndicator()
            navigationBarView
            CustomIconGridView { icon, color in
                onIconSelect(icon, color)
                dismiss()
            }
        }
    }
    
    private var navigationBarView: some View {
        InlineNavigationBar {
            AnytypeText(Loc.changeIcon, style: .uxTitle1Semibold)
                .foregroundColor(.Text.primary)
                .multilineTextAlignment(.center)
        } rightButton: {
            if isRemoveButtonAvailable {
                Button {
                    removeIcon()
                    dismiss()
                } label: {
                    AnytypeText(Loc.remove, style: .uxBodyRegular)
                        .foregroundColor(.Pure.red)
                }
            } else {
                EmptyView()
            }
        }
    }
}
