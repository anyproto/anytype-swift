import Foundation
import SwiftUI

struct WidgetSwipeActionView<Content: View>: View {
    
    enum DragState {
        case cancel
        case success
    }
    
    // MARK: - Gesture Config
    
    private let maxOffset: CGFloat = 130
    private let appyOffset: CGFloat = 110
    private let cancelOffset: CGFloat = 100
    private let maxStubOffset: CGFloat = 5
    private let extraMultiple: CGFloat = 0.15
    private let extraStubMultiple: CGFloat = 0.04
    
    // MARK: - State
    
    @State private var dragOffsetX: CGFloat = 0
    @State private var dragState: DragState = .cancel
    @State private var initialStartOffset: CGFloat? = nil
    @GestureState private var dragGestureActive = false
    
    private var percent: CGFloat {
        let extraPercent = max((dragOffsetX - maxOffset) * 0.0015, 0)
        let percent = abs(dragOffsetX / appyOffset)
        return min(max(percent, 0), 1) + extraPercent
    }
    
    private var contentOffset: CGFloat {
        let maxCurrentOffset = isEnable ? maxOffset : maxStubOffset
        let multiple = isEnable ? extraMultiple : extraStubMultiple
        let extraOffset = max((dragOffsetX - maxCurrentOffset) * multiple, 0)
        return min(dragOffsetX, maxCurrentOffset) + extraOffset
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
        ZStack {
                    ZStack(alignment: .trailing) {
                        Color.Widget.actionsBackground
                            .cornerRadius(16, style: .continuous)
                        
                        if isEnable {
                            VStack(spacing: 0) {
                                Image(asset: .X32.plus)
                                    .foregroundColor(.Text.white)
                                if showTitle {
                                    AnytypeText(Loc.Widgets.Actions.newObject, style: .caption2Medium)
                                        .foregroundColor(.Text.white)
                                }
                            }
                            .frame(width: 96)
                            .padding(.trailing, 18)
                            .opacity(percent)
                            .scaleEffect(CGSize(width: percent, height: percent))
                        }
                    }
                    .mask {
                        Rectangle()
                            .overlay {
                                RoundedRectangle(cornerRadius: 16)
                                    .offset(x: -contentOffset)
                                    .blendMode(.destinationOut)
                            }
                    }
            
            content
                .offset(x: -contentOffset)
        }
        .gesture(
            DragGesture(minimumDistance: 30, coordinateSpace: .local)
                .updating($dragGestureActive) { value, state, transaction in
                    state = true
                }
                .onChanged { value in
                    if initialStartOffset.isNil {
                        // ScrollView prevent this gestore for some initial offset.
                        // We handle offset from first callback and ignore unhandled offset. Save initial value for this.
                        // highPriorityGesture works without this line, but it start handle early and show offset for cancelled gesture.
                        // This is reproducery very often when widget contains horizontal scroll inside and looks not good.
                        initialStartOffset = value.translation.width
                    }
                    // Only left
                    withAnimation(.linear(duration: 0.1)) {
                        dragOffsetX = abs(min(value.translation.width - (initialStartOffset ?? 0), 0))
                        if isEnable {
                            impact()
                        }
                    }
                }
                .onEnded { value in
                    withAnimation {
                        dragOffsetX = 0
                    }
                    if dragState == .success, isEnable {
                        action()
                    }
                    dragState = .cancel
                }
        )
        .onChange(of: dragGestureActive) { _, newIsActiveValue in
            if newIsActiveValue == false {
                withAnimation {
                    dragOffsetX = 0
                }
                dragState = .cancel
                initialStartOffset = nil
            }
        }
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

