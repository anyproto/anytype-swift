import Foundation
import SwiftUI

struct MessageReplyActionView<Content: View>: View {
    
    // MARK: - Gesture Config
    
    private let minReplyWidth: CGFloat = 60
    private let replyImageWidth: CGFloat = 32
    
    // MARK: - State
    
    @State private var offsetX: CGFloat = 0
    @Binding private var centerOffsetY: CGFloat
    
    let isEnabled: Bool
    let contentHorizontalPadding: CGFloat
    let content: Content
    let action: () -> Void
    
    init(isEnabled: Bool, contentHorizontalPadding: CGFloat, centerOffsetY: Binding<CGFloat>, @ViewBuilder content: () -> Content, action: @escaping () -> Void) {
        self.isEnabled = isEnabled
        self.contentHorizontalPadding = contentHorizontalPadding
        self._centerOffsetY = centerOffsetY
        self.action = action
        self.content = content()
    }
    
    var body: some View {
        content
            .overlay(alignment: .topTrailing) {
                if isEnabled {
                    Image(asset: .X32.reply)
                        .renderingMode(.template)
                        .foregroundColor(.Control.transparentActive)
                        .padding(.trailing, -(contentHorizontalPadding + replyImageWidth))
                        .opacity(Double(-offsetX / minReplyWidth).clamped(to: 0...1))
                        .scaleEffect(Double(-offsetX / minReplyWidth).clamped(to: 0.5...1))
                        .offset(y: centerOffsetY - replyImageWidth/2)
                }
            }
            .offset(x: offsetX)
            .animation(.easeOut(duration: 0.15), value: offsetX)
            .highPriorityGesture(
                DragGesture(minimumDistance: 20)
                    .onChanged { value in
                        let dx = value.translation.width
                        let dy = value.translation.height

                        if abs(dx) > abs(dy), dx < 0 {
                            offsetX = dx
                        }
                    }
                    .onEnded { value in
                        if value.translation.width < -minReplyWidth {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            action()
                        }
                        withAnimation {
                            offsetX = 0
                        }
                    },
                isEnabled: isEnabled
            )
    }
}

