import SwiftUI


struct ObjectTypeIconPicker: View {
    
    let isRemoveButtonAvailable: Bool
    let onIconSelect: (_ emoji: CustomIcon) -> Void
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
            CustomIconGridView { icon in
                onIconSelect(icon)
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
                        .foregroundColor(.System.red)
                }
            } else {
                EmptyView()
            }
        }
    }
}
