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


class PublishedAuthoScrollData {
    @Published var autoScrollData = CustomScrollViewCoordinator.AutoScrollData()
}


struct CustomScrollView<Content>: View where Content: View {
    @State private var contentHeight: CGFloat = .zero
    @EnvironmentObject fileprivate var pageScrollViewLayout: GlobalEnvironment.OurEnvironmentObjects.PageScrollViewLayout
    @State private var autoScrollData = CustomScrollViewCoordinator.AutoScrollData()
    private var pAutoScrollData = PublishedAuthoScrollData()
    
    var content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        return InnerScrollView(contentHeight: self.$contentHeight, pageScrollViewLayout: $pageScrollViewLayout.needsLayout, autoScrollData: $autoScrollData) {
            self.content
                .modifier(ViewHeightKey())
        }
        // SwiftUI: Don't call onPreferenceChange inside InnerScrollView otherwise InnerScrollView retain this view with  self.contentHeight. It happens only with UIViewRepresentable views (they are not recreate every time as swiftui views)
        .onPreferenceChange(ViewHeightKey.self) {
                self.contentHeight = $0
        }
        .onReceive(pAutoScrollData.$autoScrollData) { value in
            self.autoScrollData = value
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
        let maxTiming = 0.02
        let minTiming = 0.005
        
        return self.modifier(ViewBoundary(checkingAnchor: anchor) { boundary in
            switch boundary {
            case .top(let intersectionRate):
                print("upperBoundary: \(intersectionRate)")
                let timing = min(minTiming / (intersectionRate * intersectionRate), maxTiming)
                self.pAutoScrollData.autoScrollData = CustomScrollViewCoordinator.AutoScrollData(timing: timing, direction: .top)
            case .bottom(let intersectionRate):
                print("bottomBoundary")
                let timing = min(minTiming / (intersectionRate * intersectionRate), maxTiming)
                self.pAutoScrollData.autoScrollData = CustomScrollViewCoordinator.AutoScrollData(timing: timing, direction: .bottom)
            case .neither:
                self.pAutoScrollData.autoScrollData = CustomScrollViewCoordinator.AutoScrollData(timing: 0, direction: nil)
                print("neither")
            }
        })
    }
    
    private struct ViewBoundary: ViewModifier {
        enum Boundary: Equatable {
            case top(intersectionRate: Double)
            case bottom(intersectionRate: Double)
            case neither
        }
        @Environment(\.showViewFrames) private var showViewFrames
        
        var checkingAnchor: Anchor<CGRect>?
        var onBoundary: (_ boundary: Boundary) -> Void
        
        func body(content: _ViewModifier_Content<CustomScrollView<Content>.ViewBoundary>) -> some View {
            content
                .onGeometryChange(compute: checkBoundary) { value in
                    self.onBoundary(value ?? .neither)
            }
//            if showViewFrames {
//                Rectangle()
//                    .stroke(Color.green)
//                    .frame(width: upperBoundary.width, height: upperBoundary.height)
//                    .position(x: upperBoundary.midX, y: upperBoundary.midY)
//                Rectangle()
//                    .stroke(Color.blue)
//                    .frame(width: bottomBoundary.width, height: bottomBoundary.height)
//                    .position(x: bottomBoundary.midX, y: bottomBoundary.midY)
//            }
        }
        
        private func checkBoundary(_ proxy: GeometryProxy) -> Boundary {
            let boundaryRatio: CGFloat = 0.15
            let frame = proxy.frame(in: .local)
            let upperBoundary = CGRect(origin: .zero, size: CGSize(width: frame.width, height: frame.height * boundaryRatio))
            
            let bottomY = frame.maxY - frame.height * boundaryRatio
            let bottomOrigin = CGPoint(x: frame.minX, y: bottomY)
            let bottomBoundary = CGRect(origin: bottomOrigin, size: CGSize(width: frame.width, height: frame.height * boundaryRatio))
            
            var boundary = Boundary.neither
            
            if let checkingAnchor = checkingAnchor {
                if upperBoundary.intersects(proxy[checkingAnchor]) {
                    let intersectionHeight = upperBoundary.maxY - proxy[checkingAnchor].minY
                    let YIntersectionRate = min(intersectionHeight / upperBoundary.height, 1)
                    boundary = .top(intersectionRate: Double(YIntersectionRate))
                } else if bottomBoundary.intersects(proxy[checkingAnchor]) {
                    let intersectionHeight = proxy[checkingAnchor].maxY - bottomBoundary.minY
                    let YIntersectionRate = min(intersectionHeight / upperBoundary.height, 1)
                    boundary = .bottom(intersectionRate: Double(YIntersectionRate))
                }
            }
            return boundary
        }
    }
}


// MARK: - InnerScrollViews

private struct InnerScrollView<Content>: UIViewRepresentable where Content: View {
    var content: Content
    @Binding var contentHeight: CGFloat
    @Binding var pageScrollViewLayout: Void
    // Scroll timer for dragging view near upper/bottom scroll view edges
    @Environment(\.timingTimer) private var scrollTimer
    @Binding var autoScrollData: CustomScrollViewCoordinator.AutoScrollData
    
    public init(contentHeight: Binding<CGFloat>, pageScrollViewLayout: Binding<Void>, autoScrollData: Binding<CustomScrollViewCoordinator.AutoScrollData>, @ViewBuilder content: () -> Content) {
        self.content = content()
        _contentHeight = contentHeight
        _pageScrollViewLayout = pageScrollViewLayout
        _autoScrollData = autoScrollData
    }
    
    // MARK: - UIViewRepresentable
    
    func makeCoordinator() -> CustomScrollViewCoordinator {
        CustomScrollViewCoordinator()
    }
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = configureScrollView(context: context)
        context.coordinator.scrollView = scrollView
        
        return scrollView
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        uiView.subviews[0].setNeedsUpdateConstraints()
        context.coordinator.autoScrollData = autoScrollData
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
    struct AutoScrollData {
        enum Direction {
            case top, bottom
        }
       var timing: TimeInterval = 0
        var direction: Direction?
    }
    
    var scrollView: UIScrollView?
    // Scroll timer for dragging view near upper/bottom scroll view edges
    @Environment(\.timingTimer) private var scrollTimer
    
    var autoScrollData: AutoScrollData {
        didSet {
            scrollTimer.timing = autoScrollData.timing
        }
    }
    
    override init() {
        self.autoScrollData = AutoScrollData()
        
        super.init()
        
        scrollTimer.fireTimer = { [weak self] in
            guard let scrollView = self?.scrollView else { return }
            
            DispatchQueue.main.async {
                var newAdditionalOffset = CGPoint(x: 0, y: 0)
                
                switch self?.autoScrollData.direction {
                case .top:
                    newAdditionalOffset = CGPoint(x: 0, y: -2)
                case .bottom:
                    newAdditionalOffset = CGPoint(x: 0, y: 2)
                case .none:
                    break
                }

                let newContentOffset = scrollView.contentOffset + newAdditionalOffset
                let endPoint = max(scrollView.contentSize.height - scrollView.bounds.height, 0)
                let maxY = min(newContentOffset.y, endPoint + 10)
                let normalizedContentOffset = CGPoint(x: 0, y: max(maxY, -10))
                
                scrollView.setContentOffset(normalizedContentOffset, animated: false)
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
