//
//  CustomLongPressGesture.swift
//  AnyType
//
//  Created by Denis Batvinkin on 16.12.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI


struct CustomLongPressGestureModifier: ViewModifier {
    func body(content: Content) -> some View {
        CustomLongPressGesture(content: content)
    }
}

struct CustomLongPressGesture<Content>: UIViewRepresentable where Content: View {
    var content: Content
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.isUserInteractionEnabled = true
        
        if let contentView = UIHostingController(rootView: content).view {
            view.addSubview(contentView)
            let longTap = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.longTap(_:)))
            let dragGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.dragGesture(_:)))
            longTap.delegate = context.coordinator
            longTap.allowableMovement = 0
            context.coordinator.longGesture = longTap
            context.coordinator.view = contentView
//            dragGesture.require(toFail: longTap)
            contentView.addGestureRecognizer(longTap)
            contentView.addGestureRecognizer(dragGesture)
            
            
            contentView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                contentView.topAnchor.constraint(equalTo: view.topAnchor),
                contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])
        }
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
    }
    
    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        var view: UIView?
        var longGesture: UILongPressGestureRecognizer?
//        var dragGesture: UIPanGestureRecognizer
        
        @objc func longTap(_ gestureRecognizer: UILongPressGestureRecognizer) {
            
            if gestureRecognizer.state == .began {
                view?.endEditing(true)
                 print("began")
            } else if gestureRecognizer.state == .recognized {
                 print("recognized")
            } else if gestureRecognizer.state == .possible {
                print("possible")
            } else if gestureRecognizer.state == .changed {
                print("changed")
            } else if gestureRecognizer.state == .ended {
                print("ended")
            } else if gestureRecognizer.state == .failed {
                print("failed")
            } else if gestureRecognizer.state == .cancelled {
                 print("cancelled")
            }
        }
        
        @objc func dragGesture(_ gestureRecognizer: UILongPressGestureRecognizer) {
            
            if gestureRecognizer.state == .began {
                 print("g began")
            } else if gestureRecognizer.state == .recognized {
                 print("g recognized")
            } else if gestureRecognizer.state == .possible {
                print("g possible")
            } else if gestureRecognizer.state == .changed {
                print("g changed")
            } else if gestureRecognizer.state == .ended {
                print("g ended")
            } else if gestureRecognizer.state == .failed {
                print("g failed")
            } else if gestureRecognizer.state == .cancelled {
                 print("g cancelled")
            }
        }
        
        // MARK: UIGestureRecognizerDelegate
        
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
        }
        
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            if gestureRecognizer == self.longGesture &&
            otherGestureRecognizer is UITapGestureRecognizer {
               return true
            }
            return false
        }
    }
}
