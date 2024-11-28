import SwiftUI

struct HomeTabBarSwipeContainer<HomeView: View, ChatView: View>: View {
    
    @Binding var tab: HomeTabState
    
    @ViewBuilder let homeView: HomeView
    @ViewBuilder let chatView: ChatView
    
    @State private var dragOffsetX: CGFloat = 0
    @State private var containerSize: CGSize = .zero
    @State private var gestureActive = false
    @Environment(\.keyboardDismiss) private var keyboardDismiss
    
    var body: some View {
        if #available(iOS 18.0, *) {
            bodyiOS18
        } else {
            bodyOldiOS
        }
    }
    
    private var bodyOldiOS: some View {
        ZStack {
            homeView
                .opacity(tab == .widgets ? 1 : 0)
            chatView
                .opacity(tab == .chat ? 1 : 0)
        }
    }
    
    @available(iOS 18.0, *)
    private var bodyiOS18: some View {
        ZStack {
            homeView
                .opacity(widgetAnimationProgress.opacity(progress: transitionPercent))
                .zIndex(widgetAnimationProgress.zIndex())
                .offset(x: widgetAnimationProgress.offsetX(progress: transitionPercent, containerWidth: containerSize.width, gestureActive: gestureActive))
            
            chatView
                .opacity(chatAnimationProgress.opacity(progress: transitionPercent))
                .zIndex(chatAnimationProgress.zIndex())
                .offset(x: chatAnimationProgress.offsetX(progress: transitionPercent, containerWidth: containerSize.width, gestureActive: gestureActive))
        }
        .readSize {
            containerSize = $0
        }
        .gesture(HomeTabLeftToRightGesture {
            keyboardDismiss()
            gestureActive = true
        } onChange: { translate, velocity in
            dragOffsetX = max(translate, 0)
        } onEnd: { translate, velocity in
            let switchScreen = transitionPercent > 0.3 || velocity > 1000
            
                if switchScreen {
                    let duration = animationDiration(distance: containerSize.width - translate, velocity: velocity)
                    withAnimation(.easeOut(duration: duration)) {
                        dragOffsetX = containerSize.width
                    } completion: {
                        switchTab()
                        dragOffsetX = 0
                        gestureActive = false
                    }
                } else {
                    let duration = animationDiration(distance: translate, velocity: velocity)
                    withAnimation(.easeOut(duration: duration)) {
                        dragOffsetX = 0
                    } completion: {
                        gestureActive = false
                    }
                }
        })
    }
    
    private var transitionPercent: CGFloat {
        guard containerSize.width > 0 else { return 0 }
        return (containerSize.width - max(containerSize.width - dragOffsetX, 0)) / containerSize.width
    }
    
    private var chatAnimationProgress: HomeTabBarAnimationProgress {
        switch tab {
        case .widgets:
            return gestureActive ? .showInProgress : .readyToShow
        case .chat:
            return gestureActive ? .hiddenInProgress : .show
        }
    }
    
    private var widgetAnimationProgress: HomeTabBarAnimationProgress {
        switch tab {
        case .widgets:
            return gestureActive ? .hiddenInProgress : .show
        case .chat:
            return gestureActive ? .showInProgress : .readyToShow
        }
    }
    
    private func animationDiration(distance: CGFloat, velocity: CGFloat) -> TimeInterval {
        let minimumVelocity: CGFloat = 100.0
        let adjustedVelocity = max(velocity, minimumVelocity)
        var duration = TimeInterval(distance / adjustedVelocity)
        duration = min(max(duration, 0.15), 0.25)
        return duration
    }
    
    func switchTab() {
        switch tab {
        case .widgets:
            tab = .chat
        case .chat:
            tab = .widgets
        }
    }
}
