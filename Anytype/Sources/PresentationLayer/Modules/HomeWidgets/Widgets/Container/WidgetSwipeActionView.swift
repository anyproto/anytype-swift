import Foundation
import SwiftUI

struct WidgetSwipeActionView<Content: View>: View {
    
    enum DragState {
        case cancel
        case success
    }
    
    @State private var dragOffsetX: CGFloat = 0
    @State private var dragState: DragState = .cancel
    
    private let maxOffset: CGFloat = 130
    private let appyOffset: CGFloat = 110
    private let cancelOffset: CGFloat = 100
    
    private var percent: CGFloat {
        let extraPercent = max((dragOffsetX - maxOffset) * 0.0015, 0)
        let percent = abs(dragOffsetX / appyOffset)
        return min(max(percent, 0), 1) + extraPercent
    }
    
    private var contentOffset: CGFloat {
        let extraOffset = max((dragOffsetX - maxOffset) * 0.15, 0)
        return min(dragOffsetX, maxOffset) + extraOffset
    }
    
    let isEnable: Bool
    let showTitle: Bool
    let action: () -> Void
    let content: Content
    
    init(isEnable: Bool, showTitle: Bool, action: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.isEnable = isEnable
        self.showTitle = showTitle
        self.action = action
        self.content = content()
    }
    
    var body: some View {
        if isEnable {
            container
        } else {
            content
        }
    }
    
    private var container: some View {
        ZStack {
            ZStack(alignment: .trailing) {
                Color.Text.primary.opacity(0.25)
                        .cornerRadius(16, style: .continuous)
            
                VStack(spacing: 0) {
                    Image(asset: .X32.plus)
                        .foregroundColor(.Text.white)
                    if showTitle {
                        AnytypeText(Loc.Widgets.Actions.newObject, style: .caption2Medium, color: .Text.white)
                    }
                }
                .frame(width: 96)
                .padding(.trailing, 18)
                .opacity(percent)
                .scaleEffect(CGSize(width: percent, height: percent))
            }
            
            content
                .offset(x: -contentOffset)
        }
        .gesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .local)
                .onChanged { value in
                    // Only left
                    withAnimation(.linear(duration: 0.1)) {
                        dragOffsetX = abs(min(value.translation.width, 0))
                        impact()
                    }
                }
                .onEnded { value in
                    withAnimation {
                        dragOffsetX = 0
                    }
                    if dragState == .success {
                        action()
                    }
                    dragState = .cancel
                }
        )
    }
    
    private func impact() {
        switch dragState {
        case .cancel:
            if dragOffsetX >= appyOffset {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                dragState = .success
            }
        case .success:
            if dragOffsetX <= cancelOffset {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                dragState = .cancel
            }
        }
    }
}

