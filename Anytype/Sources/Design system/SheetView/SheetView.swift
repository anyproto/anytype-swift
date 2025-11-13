import SwiftUI

struct SheetView<Content: View>: View {
    @Environment(\.dismiss) private var dismiss
    
    private let dismissOnBackgroundView: Bool
    private var content: Content
    private let cancelAction: (() -> Void)?
    
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
        content
            .cornerRadius(34, style: .continuous)
            .shadow(radius: 20)
            .padding(.horizontal, 8)
            .gesture(
                DragGesture()
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
