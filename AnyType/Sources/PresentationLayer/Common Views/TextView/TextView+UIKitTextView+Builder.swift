//
//  TextView+UIKitTextView+Builder.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 13.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit

extension TextView.UIKitTextView {
    class Builder {
        init() {}
    }
}

extension TextView.UIKitTextView.Builder {
    typealias Coordinator = TextView.UIKitTextView.Coordinator
    private func createTextView() -> UITextView {
        let textView = UITextView()
        return textView
    }
    
    func defaultConfiguration(_ textView: UITextView) -> UITextView {
        textView.font = .preferredFont(forTextStyle: .title1)
        textView.textContainer.lineFragmentPadding = 0.0
        textView.textContainerInset = .zero
        textView.isScrollEnabled = false
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return textView
    }
    
    func configuredTextView(_ textView: UITextView, coordinator: Coordinator) -> UITextView {
        // TODO: add text?
        let view = defaultConfiguration(textView)
        
        let attributedString = NSMutableAttributedString(string: "")
        let attributes: [NSAttributedString.Key : Any] = [.font : UIFont.preferredFont(forTextStyle: .body)]
        let range = NSRange(location: 0, length: attributedString.length)
                
        view.typingAttributes = attributes
        view.textStorage.setAttributedString(attributedString)
        view.textStorage.setAttributes(attributes, range: range)
        view.delegate = coordinator
        view.autocorrectionType = .no
        
        //        _ = configuredTapGesture(textView, context: context)
        return view
    }
    
    func configuredTapGesture(_ textView: UITextView, coordinator: Coordinator) -> UITextView {
        let tapGesture = UITapGestureRecognizer(target: coordinator, action: #selector(Coordinator.tap(_:)))
        tapGesture.delegate = coordinator
        textView.addGestureRecognizer(tapGesture)
        return textView
    }
    
    func makeUIView(coordinator: Coordinator) -> UITextView {
        return makeUIView(createTextView(), coordinator: coordinator)
    }
    
    func makeUIView(_ textView: UITextView, coordinator: Coordinator) -> UITextView {
        let textView = configuredTextView(textView, coordinator: coordinator)
        coordinator.configureMarkStylePublisher(textView)
        coordinator.configureBlocksToolbarHandler(textView)
        return textView
    }
}
