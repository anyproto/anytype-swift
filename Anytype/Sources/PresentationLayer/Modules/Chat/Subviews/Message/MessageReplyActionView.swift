import Foundation
import SwiftUI

struct MessageReplyActionView<Content: View>: View {
    
    // MARK: - Gesture Config
    
    private let minReplyWidth: CGFloat = 50
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
        if #available(iOS 18.0, *), isEnabled {
            contentWithReply
        } else {
            content
        }
    }
    
    @available(iOS 18.0, *)
    private var contentWithReply: some View {
        content
            .overlay(alignment: .topTrailing) {
                Image(asset: .X32.reply)
                    .renderingMode(.template)
                    .foregroundColor(.Control.transparentActive)
                    .padding(.trailing, -(contentHorizontalPadding + replyImageWidth))
                    .opacity(Double(-offsetX / minReplyWidth).clamped(to: 0...1))
                    .scaleEffect(Double(-offsetX / minReplyWidth).clamped(to: 0.5...1))
                    .offset(y: centerOffsetY - replyImageWidth/2)
            }
            .offset(x: offsetX)
            .animation(.easeOut(duration: 0.15), value: offsetX)
            .gesture(MessageReplyGestureRecognizer(handleAction: { gesture in
                let translation = gesture.translation(in: gesture.view)
                switch gesture.state {
                case .changed:
                    if translation.x < 0 {
                        offsetX = translation.x
                    }
                case .ended:
                    if abs(translation.x) > minReplyWidth {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        action()
                    }
                    withAnimation {
                        offsetX = 0
                    }
                default:
                    break
                }
            }))
    }
}
