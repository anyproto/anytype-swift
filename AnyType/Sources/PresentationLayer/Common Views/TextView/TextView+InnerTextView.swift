//
//  TextView+InnerTextView.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 01.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
import Combine

// MARK: InnerTextView
extension TextView {
    struct InnerTextView {
        @Binding var text: String
        @Binding var sizeThatFit: CGSize
        @ObservedObject var wholeTextMarkStyleKeeper: TextView.MarkStyleKeeper
        @EnvironmentObject var outerViewNeedsLayout: GlobalEnvironment.OurEnvironmentObjects.PageScrollViewLayout
        
        weak var delegate: TextViewUserInteractionProtocol?
        
        init(text: Binding<String>, sizeThatFit: Binding<CGSize>, wholeTextMarkStyleKeeper: ObservedObject<TextView.MarkStyleKeeper>) {
            _text = text
            _sizeThatFit = sizeThatFit
            _wholeTextMarkStyleKeeper = wholeTextMarkStyleKeeper
        }
        init(text: Binding<String>, sizeThatFit: Binding<CGSize>, wholeTextMarkStyleKeeper: ObservedObject<TextView.MarkStyleKeeper>, delegate: TextViewUserInteractionProtocol?) {
            self.init(text: text, sizeThatFit: sizeThatFit, wholeTextMarkStyleKeeper: wholeTextMarkStyleKeeper)
            self.delegate = delegate
        }
    }
}

// MARK: InnerTextView / UIViewRepresentable
extension TextView.InnerTextView: UIViewRepresentable {
    // MARK: - Private methods
    
    private func createTextView() -> UITextView {
        let textView = UITextView()
        textView.font = .preferredFont(forTextStyle: .title1)
        textView.textContainer.lineFragmentPadding = 0.0
        textView.textContainerInset = .zero
        textView.isScrollEnabled = false
        //TODO: add debug here.
        //        textView.backgroundColor = UIColor(white: 0.0, alpha: 0.05)
        //        textView.backgroundColor = .clear
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        return textView
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    func configuredTextView(_ textView: UITextView, context: Context) -> UITextView {
        let attributedString = NSMutableAttributedString(string: text)
        let attributes: [NSAttributedString.Key : Any] = [.font : UIFont.preferredFont(forTextStyle: .body)]
        let range = NSRange(location: 0, length: attributedString.length)
        textView.typingAttributes = attributes
        textView.textStorage.setAttributedString(attributedString)
        textView.textStorage.setAttributes(attributes, range: range)
        textView.delegate = context.coordinator
        textView.autocorrectionType = .no
        
//        _ = configuredTapGesture(textView, context: context)
        return textView
    }
    
    func configuredTapGesture(_ textView: UITextView, context: Context) -> UITextView {
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.tap(_:)))
        tapGesture.delegate = context.coordinator
        textView.addGestureRecognizer(tapGesture)
        return textView
    }
    
    func makeUIView(context: Context) -> UITextView {
        let textView = self.configuredTextView(createTextView(), context: context)
        context.coordinator.configureMarkStylePublisher(textView)
        context.coordinator.configureBlocksToolbarHandler(textView)
        
//        if context.coordinator.userInteractionDelegate == nil {            
//            context.coordinator.userInteractionDelegate = context.coordinator
//        }
        
        DispatchQueue.main.async {
            self.sizeThatFit = textView.intrinsicContentSize
        }
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        context.coordinator.updateWholeMarkStyle(uiView, wholeMarkStyleKeeper: self.wholeTextMarkStyleKeeper)
    }
}

// MARK: InnerTextView / Coordinator
extension TextView.InnerTextView {
    class Coordinator: NSObject {
        // MARK: Aliases
        typealias HighlightedAccessoryView = TextView.HighlightedToolbar.AccessoryView
        typealias BlockToolbarAccesoryView = TextView.BlockToolbar.AccessoryView
        
        // MARK: Variables
        var parent: TextView.InnerTextView
        
        @EnvironmentObject var outerViewNeedsLayout: GlobalEnvironment.OurEnvironmentObjects.PageScrollViewLayout
        
        weak var userInteractionDelegate: TextViewUserInteractionProtocol?
        func configure(_ delegate: TextViewUserInteractionProtocol?) -> Self {
            self.userInteractionDelegate = delegate
            return self
        }
        
        lazy var highlightedAccessoryView: HighlightedAccessoryView = .init()
        var highlightedAccessoryViewHandler: (((NSRange, NSTextStorage)) -> ())?
        
        var highlightedMarkStyleHandler: AnyCancellable?
        var wholeMarkStyleHandler: AnyCancellable?
        
        lazy var blocksAccessoryView: BlockToolbarAccesoryView = .init()
        var blocksAccessoryViewHandler: AnyCancellable?
        var blocksUserActionsHandler: AnyCancellable?
        
        var defaultKeyboardRect: CGRect = .zero
                
        // MARK: - Initiazliation
        init(_ uiTextView: TextView.InnerTextView) {
            self.parent = uiTextView
            self._outerViewNeedsLayout = uiTextView._outerViewNeedsLayout
            self.userInteractionDelegate = uiTextView.delegate
            super.init()
            self.setup()
        }
        
        func setup() {
            self.configureInnerAccessoryViewHandler()
            self.configureKeyboardNotificationsListening()
        }
                
        // MARK: Keyboard Handling
        @objc func keyboardWillShow(notification: Notification) {
            if self.defaultKeyboardRect == .zero, let rect = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                // NOTE: we should save default keyboard size to set input views frames of textView correctly.
                self.defaultKeyboardRect = rect
            }
        }
        
        func configureKeyboardNotificationsListening() {
            NotificationCenter.default.addObserver(self, selector: #selector(Self.keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        }
    }
}
