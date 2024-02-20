import SwiftUI

struct SheetView<Content: View>: View {
    @Environment(\.dismiss) private var dismiss
    
    private var content: Content
    private let cancelAction: (() -> Void)?
    
    init(content: () -> Content, cancelAction: (() -> Void)?) {
        self.content = content()
        self.cancelAction = cancelAction
    }
      
    var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
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
            .cornerRadius(16, style: .continuous)
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
