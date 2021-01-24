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
        TextView.UIKitTextView.TextViewWithPlaceholder.init()
    }
    
    func defaultConfiguration(_ textView: UITextView) -> UITextView {
        textView.font = .preferredFont(forTextStyle: .title1)
        textView.textContainer.lineFragmentPadding = 0.0
        textView.textContainerInset = .zero
        textView.isScrollEnabled = false
        textView.backgroundColor = nil
        return textView
    }
    
    func configured(textView: UITextView) -> UITextView {
        let view = defaultConfiguration(textView)
        
        let attributedString = NSMutableAttributedString(string: "")
        let attributes: [NSAttributedString.Key : Any] = [.font : UIFont.preferredFont(forTextStyle: .body)]
        let range = NSRange(location: 0, length: attributedString.length)
                
        view.typingAttributes = attributes
        view.textStorage.setAttributedString(attributedString)
        view.textStorage.setAttributes(attributes, range: range)
        view.autocorrectionType = .no
        return view
    }
    
    func configuredTextView(_ textView: UITextView, textViewDelegate: UITextViewDelegate) -> UITextView {
        // TODO: add text?
        let view = self.configured(textView: textView)
        
        view.delegate = textViewDelegate
        
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
        return self.makeUIView(self.createTextView(), coordinator: coordinator)
    }
    
    func makeUIView(_ textView: UITextView, coordinator: Coordinator) -> UITextView {
        let textView = configuredTextView(textView, textViewDelegate: coordinator)
        coordinator.configureActionsToolbarHandler(textView)
        if let smartTextView = textView as? TextView.UIKitTextView.TextViewWithPlaceholder {
            _ = coordinator.configured(textStorageStream: smartTextView.textStorageEventsPublisher)
            _ = coordinator.configured(textView, contextualMenuStream: smartTextView.contextualMenuPublisher)
        }
        coordinator.configureMarksPanePublisher(textView)
        return textView
    }
}
