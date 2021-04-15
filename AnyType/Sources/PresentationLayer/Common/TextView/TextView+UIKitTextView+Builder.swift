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

    func makeUIView(_ textView: UITextView, coordinator: Coordinator) -> UITextView {
        let textView = configuredTextView(textView, textViewDelegate: coordinator)
        coordinator.configureEditingToolbarHandler(textView)

        if let smartTextView = textView as? TextView.UIKitTextView.TextViewWithPlaceholder {
            _ = coordinator.configured(textView, contextualMenuStream: smartTextView.contextualMenuPublisher)
            // When sending signal with send() in textView
            // textStorageEventsSubject subscribers installed
            // in coordinator configured(textStorageStream:)
            // method have not being called, it leads us to
            // deleting text in textView without updating it in block model
            smartTextView.coordinator = coordinator
        }
        coordinator.configureMarksPanePublisher(textView)
        return textView
    }

    func configuredTextView(_ textView: UITextView, textViewDelegate: UITextViewDelegate) -> UITextView {
        // TODO: add text?
        let view = self.configured(textView: textView)

        view.delegate = textViewDelegate

        //        _ = configuredTapGesture(textView, context: context)
        return view
    }

    private func configured(textView: UITextView) -> UITextView {
        textView.textContainer.lineFragmentPadding = 0.0
        textView.isScrollEnabled = false
        textView.backgroundColor = nil
        textView.autocorrectionType = .no
        return textView
    }
    
    private func configuredTapGesture(_ textView: UITextView, coordinator: Coordinator) -> UITextView {
        let tapGesture = UITapGestureRecognizer(target: coordinator, action: #selector(Coordinator.tap(_:)))
        tapGesture.delegate = coordinator
        textView.addGestureRecognizer(tapGesture)
        return textView
    }
}
