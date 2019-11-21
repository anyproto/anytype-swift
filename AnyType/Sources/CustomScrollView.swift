//
//  CustomScrollView.swift
//  AnyType
//
//  Created by Denis Batvinkin on 20.11.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI


struct CustomScrollView<Content>: UIViewRepresentable where Content: View {
    var content: Content
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    // MARK: - UIViewRepresentable
    
    func makeCoordinator() -> CustomScrollViewCoordinator<Content> {
        CustomScrollViewCoordinator(self)
    }
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = configureScrollView()
        populate()
        
        return scrollView
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        populate()
    }
    
    private func populate() {
    }
}


extension CustomScrollView {
    
    private func configureScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        
        if let contentView = UIHostingController(rootView: content).view {
            scrollView.addSubview(contentView)
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
        scrollView.alwaysBounceVertical = true
        scrollView.backgroundColor = .clear
        
        return scrollView
    }
}


// MARK: - Coordinator

class CustomScrollViewCoordinator<Content>: NSObject where Content: View {
    var parent: CustomScrollView<Content>
    
    init(_ scrollView: CustomScrollView<Content>) {
        self.parent = scrollView
    }
}


// MARK: - Preview

struct CustomScrollView_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack {
            CustomScrollView {
                ForEach(1...50, id: \.self) { i in
                    TestView(index: i)
                }
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
