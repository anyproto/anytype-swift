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
            @Published var needsLayout: Bool = false
        }
    }
}

var scrollModelInst: Int = 0

fileprivate class ScrollTimer {
    private var numberOfInstance: Int = 0
    
    var fireTimer: (() -> Void)?
    
    private var timer = Timer.publish(every: 1, on: .main, in: .common)
    private var cancellableTimer: AnyCancellable?
    
    var velocity: CGPoint = .zero {
        didSet {
            guard oldValue.y != velocity.y else { return }
            
            self.cancellableTimer?.cancel()
            print("cancel timer")
            
            if velocity.y != 0 {
                timer = Timer.publish(every: 1, on: .main, in: .common)
                cancellableTimer = timer.autoconnect().sink { [weak self] _ in
                    self?.fireTimer?()
                }
                print("start timer")
            }
        }
    }
    
    init() {
        scrollModelInst += 1
        numberOfInstance = scrollModelInst
        print("init \(numberOfInstance)")
    }
    
    deinit {
        print("deinit \(numberOfInstance)")
        self.cancellableTimer?.cancel()
    }
}

struct CustomScrollView<Content>: View where Content: View {
    var content: Content
    
    @State private var contentHeight: CGFloat = .zero
    @EnvironmentObject fileprivate var pageScrollViewLayout: GlobalEnvironment.OurEnvironmentObjects.PageScrollViewLayout
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        InnerScrollView(contentHeight: self.$contentHeight, pageScrollViewLayout: $pageScrollViewLayout.needsLayout) {
            self.content
                .modifier(ViewHeightKey())
        }
            // SwiftUI: Don't call onPreferenceChange inside InnerScrollView otherwise InnerScrollView retain this view with  self.contentHeight. It happens only with UIViewRepresentable views (they are not recreate every time as swiftui views)
            .onPreferenceChange(ViewHeightKey.self) {
                self.contentHeight = $0
        }
    }
    
    func scrollViewOffset(offset: CGPoint) -> some View {
        // SwiftUI: use environment cause we can't change local view state here from func that called in context parent view
        self.environment(\.scrollViewOffsetVelocity, offset)
    }
}

struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat {
        0
    }
    
    static func reduce(value: inout Value, nextValue: () -> Value) {
        //        value = nextValue()
    }
}

extension ViewHeightKey: ViewModifier {
    func body(content: Content) -> some View {
        return content.background(GeometryReader { proxy in
            Color.clear.preference(key: ViewHeightKey.self, value: proxy.size.height)
        })
    }
}

// MARK: - InnerScrollViews

private struct InnerScrollView<Content>: UIViewRepresentable where Content: View {
    var content: Content
    @Binding var contentHeight: CGFloat
    @Binding var pageScrollViewLayout: Bool
    @Environment(\.scrollViewOffsetVelocity) private var offsetVelocity: CGPoint
    
    public init(contentHeight: Binding<CGFloat>, pageScrollViewLayout: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self.content = content()
        _contentHeight = contentHeight
        _pageScrollViewLayout = pageScrollViewLayout
    }
    
    // MARK: - UIViewRepresentable
    
    func makeCoordinator() -> CustomScrollViewCoordinator {
        CustomScrollViewCoordinator()
    }
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = configureScrollView(context: context)
        
        return scrollView
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        context.coordinator.setContentOffsetVelocity(self.offsetVelocity, for: uiView)
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
    private var scrollModel = ScrollTimer()
    
    func setContentOffsetVelocity(_ velocity: CGPoint, for scrollView: UIScrollView) {
        scrollModel.velocity = velocity
        
        scrollModel.fireTimer = { [weak scrollView] in
            scrollView?.contentOffset += velocity
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
