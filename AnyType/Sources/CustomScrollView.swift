//
//  CustomScrollView.swift
//  AnyType
//
//  Created by Denis Batvinkin on 20.11.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI
import Combine


enum GlobalEnvironment {
    // Inject them!
    enum OurEnvironmentObjects {
        class PageScrollViewLayout: ObservableObject {
            @Published var needsLayout: Void = ()
        }
    }
}


struct CustomScrollView<Content>: View where Content: View {
    @State private var contentHeight: CGFloat = .zero
    @EnvironmentObject fileprivate var pageScrollViewLayout: GlobalEnvironment.OurEnvironmentObjects.PageScrollViewLayout
    // Scroll timer for dragging view near upper/bottom scroll view edges
    @Environment(\.timingTimer) private var scrollTimer
    
    var content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        InnerScrollView(contentHeight: self.$contentHeight, pageScrollViewLayout: $pageScrollViewLayout.needsLayout, timer: scrollTimer) {
            self.content
                .modifier(ViewHeightKey())
        }
        // SwiftUI: Don't call onPreferenceChange inside InnerScrollView otherwise InnerScrollView retain this view with  self.contentHeight. It happens only with UIViewRepresentable views (they are not recreate every time as swiftui views)
        .onPreferenceChange(ViewHeightKey.self) {
                self.contentHeight = $0
        }
    }
}


extension CustomScrollView {
    
    struct ViewHeightKey: PreferenceKey, ViewModifier {
        static var defaultValue: CGFloat {
            0
        }
        
        static func reduce(value: inout Value, nextValue: () -> Value) {
            //        value = nextValue()
        }
        
        func body(content: _ViewModifier_Content<CustomScrollView<Content>.ViewHeightKey>) -> some View {
            return content.background(GeometryReader { proxy in
                Color.clear.preference(key: ViewHeightKey.self, value: proxy.size.height)
            })
        }
    }
}


// MARK: - Boundary stuff

extension CustomScrollView {
    
    func scrollIfAnchorIntersectBoundary(anchor: Anchor<CGRect>?) -> some View {
        let maxTiming = 0.06
        let power = 15.0 //
        
        return self.modifier(ViewBoundary(checkingAnchor: anchor) { boundary in
            switch boundary {
            case .top(let intersectionRate):
                print("upperBoundary: \(intersectionRate)")
                self.scrollTimer.timing = (intersectionRate + maxTiming) / (intersectionRate * intersectionRate * power)
            case .bottom(let intersectionRate):
                print("bottomBoundary")
                self.scrollTimer.timing = (intersectionRate + maxTiming) / (intersectionRate * intersectionRate * power)
            case .neither:
                self.scrollTimer.timing = 0.0
                print("neither")
            }
        })
    }
    
    private struct ViewBoundary: ViewModifier {
        enum Boundary {
            case top(intersectionRate: Double), bottom(intersectionRate: Double)
            case neither
        }
        @Environment(\.showViewFrames) private var showViewFrames
        
        var checkingAnchor: Anchor<CGRect>?
        var onBoundary: (_ boundary: Boundary) -> Void
        
        func body(content: _ViewModifier_Content<CustomScrollView<Content>.ViewBoundary>) -> some View {
            content.overlay(
                GeometryReader { proxy in
                    self.checkBoundary(proxy: proxy)
            })
        }
        
        private func checkBoundary(proxy: GeometryProxy) -> some View {
            let frame = proxy.frame(in: .local)
            let upperBoundary = CGRect(origin: .zero, size: CGSize(width: frame.width, height: frame.height * 0.15))
            
            let bottomY = frame.maxY - frame.height * 0.15
            let bottomOrigin = CGPoint(x: frame.minX, y: bottomY)
            let bottomBoundary = CGRect(origin: bottomOrigin, size: CGSize(width: frame.width, height: frame.height * 0.15))
            
            if let checkingAnchor = checkingAnchor {
                if upperBoundary.intersects(proxy[checkingAnchor]) {
                    let intersectionHeight = upperBoundary.maxY - proxy[checkingAnchor].minY
                    let YIntersectionRate = intersectionHeight / upperBoundary.height
                    onBoundary(.top(intersectionRate: Double(YIntersectionRate)))
                } else if bottomBoundary.intersects(proxy[checkingAnchor]) {
                    let intersectionHeight = proxy[checkingAnchor].maxY - bottomBoundary.minY
                    let YIntersectionRate = intersectionHeight / upperBoundary.height
                    onBoundary(.bottom(intersectionRate: Double(YIntersectionRate)))
                } else {
                    onBoundary(.neither)
                }
            } else {
                onBoundary(.neither)
            }
            
            return ZStack {
                Color.clear
                
                if showViewFrames {
                    Rectangle()
                        .stroke(Color.green)
                        .frame(width: upperBoundary.width, height: upperBoundary.height)
                        .position(x: upperBoundary.midX, y: upperBoundary.midY)
                    Rectangle()
                        .stroke(Color.blue)
                        .frame(width: bottomBoundary.width, height: bottomBoundary.height)
                        .position(x: bottomBoundary.midX, y: bottomBoundary.midY)
                }
            }
        }
    }
}


// MARK: - InnerScrollViews

private struct InnerScrollView<Content>: UIViewRepresentable where Content: View {
    var content: Content
    @Binding var contentHeight: CGFloat
    @Binding var pageScrollViewLayout: Void
    
    @State var timer: TimingTimer
    
    public init(contentHeight: Binding<CGFloat>, pageScrollViewLayout: Binding<Void>, timer: TimingTimer, @ViewBuilder content: () -> Content) {
        self.content = content()
        _contentHeight = contentHeight
        _pageScrollViewLayout = pageScrollViewLayout
        _timer = State(initialValue: timer)
    }
    
    // MARK: - UIViewRepresentable
    
    func makeCoordinator() -> CustomScrollViewCoordinator {
        CustomScrollViewCoordinator(timer: timer)
    }
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = configureScrollView(context: context)
        context.coordinator.scrollView = scrollView
        
        return scrollView
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        uiView.subviews[0].setNeedsUpdateConstraints()
    }
}


extension InnerScrollView {
    
    private func setContentViewLayout(for contentView: UIView, to scrollView: UIScrollView) {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        let contentGuide = scrollView.contentLayoutGuide
        
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: contentGuide.leadingAnchor),
            contentView.topAnchor.constraint(equalTo: contentGuide.topAnchor),
            contentView.trailingAnchor.constraint(equalTo: contentGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: contentGuide.bottomAnchor),
            
            // HERE: Uncomment me if you want to look at fun animations
            //            contentGuide.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor),
            contentGuide.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
        ])
    }
    

    class MyScollView: UIScrollView, UIGestureRecognizerDelegate {
        
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
        }
        
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
        }
    }
    
    private func configureScrollView(context: Context) -> UIScrollView {
        let scrollView = MyScollView()
        
        if let contentView = UIHostingController(rootView: content).view {
            scrollView.addSubview(contentView)
            setContentViewLayout(for: contentView, to: scrollView)
        }
        scrollView.alwaysBounceVertical = true
        scrollView.backgroundColor = .clear
    
        return scrollView
    }
}

// MARK: - Coordinator

class CustomScrollViewCoordinator: NSObject, UIScrollViewDelegate {
    var scrollView: UIScrollView?
    
    init(timer: TimingTimer) {
        super.init()
        
        timer.fireTimer = { [weak self] in
            DispatchQueue.main.async {
                let contentOffset = (self?.scrollView?.contentOffset ?? .zero) + CGPoint(x: 0, y: 20)
                self?.scrollView?.setContentOffset(contentOffset, animated: true)
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    }
}


// MARK: - Preview

struct CustomScrollView_Previews: PreviewProvider {
    
    static var previews: some View {
        CustomScrollView {
            ForEach(1...33, id: \.self) { i in
                TestView(index: i)
            }
        }
    }
}


struct TestView: View {
    @State var offset: CGFloat = 0
    var index: Int
    
    var body: some View {
        Button(action: {
            self.offset += 10
        }) {
            Text("someText \(index)").padding(.top, offset)
        }
    }
}
