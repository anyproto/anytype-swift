//
//  CustomScrollView.swift
//  AnyType
//
//  Created by Denis Batvinkin on 20.11.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI


private class ScrollModel: ObservableObject {
    var velocity: CGPoint
    
    init(velocity: CGPoint) {
        self.velocity = velocity
    }
}

struct CustomScrollView<Content>: View where Content: View {
    var content: Content
    @State private var contentHeight: CGFloat = .zero
    @ObservedObject fileprivate var scrollModel: ScrollModel = ScrollModel(velocity: .zero)
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        InnerScrollView(contentHeight: self.$contentHeight, contentOffset: $scrollModel.velocity) {
            self.content
                .modifier(ViewHeightKey())
                .onPreferenceChange(ViewHeightKey.self) {
                    self.contentHeight = $0
                    print("customH: \(self.contentHeight)")
            }
        }
    }
    
    func scrollViewOffset(offset: CGPoint) -> some View {
        scrollModel.velocity = offset
        
        return self
    }
}


struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat {
        0
    }
    
    static func reduce(value: inout Value, nextValue: () -> Value) {
        //        value = nextValue()
        print("reduced \(value)")
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
    @Binding var contentOffset: CGPoint
    
    public init(contentHeight: Binding<CGFloat>, contentOffset: Binding<CGPoint>, @ViewBuilder content: () -> Content) {
        self.content = content()
        _contentHeight = contentHeight
        _contentOffset = contentOffset
    }
    
    // MARK: - UIViewRepresentable
    
    func makeCoordinator() -> CustomScrollViewCoordinator {
        CustomScrollViewCoordinator()
    }
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = configureScrollView()
        populate()
        
        return scrollView
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        uiView.subviews[0].setNeedsUpdateConstraints()
        
        populate()
    }
    
    private func populate() {
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
            
            contentGuide.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
        ])
    }
    
    private func configureScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        
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
