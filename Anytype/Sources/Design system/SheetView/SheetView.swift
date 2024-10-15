import SwiftUI

struct SheetView<Content: View>: View {
    @Environment(\.dismiss) private var dismiss
    
    private let dismissOnBackgroundView: Bool
    private var content: Content
    private let cancelAction: (() -> Void)?

    @State private var spacerHeight: CGFloat = 0

    init(
        dismissOnBackgroundView: Bool,
        content: () -> Content,
        cancelAction: (() -> Void)?
    ) {
        self.dismissOnBackgroundView = dismissOnBackgroundView
        self.content = content()
        self.cancelAction = cancelAction
    }
      
    var body: some View {
        ZStack {
            Color.clear
                .fixTappableArea()
                .onTapGesture {
                    guard dismissOnBackgroundView else { return }
                    dismiss()
                    cancelAction?()
                }
            VStack(spacing: 0) {
                Spacer()
                contentView
            }
        }
        .padding(.bottom, 10)
    }
    
    private var contentView: some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(max(0, spacerHeight))
            VStack(spacing: 0) {
                DragIndicator()
                Spacer.fixedHeight(12)
                content
            }
            .background(Color.Background.secondary)
            .cornerRadius(16, style: .continuous)
            .shadow(radius: 20)
            .padding(.horizontal, 8)
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    spacerHeight = value.translation.height
                }
                .onEnded { value in
                    if value.translation.height > 0 {
                        dismiss()
                        cancelAction?()
                    }
                }
        )
        .fitIPadToReadableContentGuide()
    }
}
