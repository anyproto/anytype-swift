//
//  TextView+UIKitTextView+ViewModel.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 14.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit
import Combine

// UIView -> Coordinator -> Delegate -> ...
// UIView -> Coordinator.text -> ???
// UIView <- ViewModel <(Update)- ViewModel ( special model )
extension TextView.UIKitTextView {
    class ViewModel {
        // For View
        @Published var update: Update = .unknown
        @Published var shouldSetFocus: Bool = false
        
        // For OuterWorld.
        /// First publisher which manipulates plain old string, text.
        var updatePublisher: AnyPublisher<Update, Never> = .empty()
        
        /// Second publisher which manipulates rich string, attributed string.
        var richUpdatePublsiher: AnyPublisher<Update, Never> = .empty()
        
        
        private var builder: Builder = .init()
        private var coordinator: Coordinator = .init()
        
        init() {
            self.setup()
        }
        
        private func setup() {
            /// NOTE:
            /// We should skip value `default @Published variable value`.
            /// For that reason we change type of $text to @Published<Optional<String>>.
            /// We create compelled distance between String values (which are coming from UITextView) and "no value". ( default value )
            /// In this case we prefer to filter values rather than blindly `dropFirst` values.
            ///
            
            /// We add `removeDuplicates()` filtering, because...
            /// Because
            /// 1. we are setting attributes programmatically.
            /// 2. we are also listening textStorageDelegate for that.
            /// 3. we also use `setAttributedString` of textStorage.
            /// In this circumstances, it is better to remove duplicates of attributedString...
            /// You could build a cycle of events in these circumstances, it is very bad.
            self.updatePublisher = self.coordinator.$text.safelyUnwrapOptionals().removeDuplicates().map(Update.text).eraseToAnyPublisher()
            self.richUpdatePublsiher = self.coordinator.$attributedText.safelyUnwrapOptionals().removeDuplicates().map(Update.attributedText).eraseToAnyPublisher()
        }
        
        convenience init(_ delegate: TextViewUserInteractionProtocol?) {
            self.init()
            _ = self.configured(delegate)
        }
    }
}

// MARK: State
extension TextView.UIKitTextView.ViewModel {
    enum Update {
        case unknown
        case text(String)
        case attributedText(NSAttributedString)
    }
    func apply(update: Update) {
        // publish update?
        self.update = update
    }
}

// MARK: Focus
extension TextView.UIKitTextView.ViewModel {
    func set(focus: Bool) {
        self.shouldSetFocus = focus
    }
}

// MARK: View
extension TextView.UIKitTextView.ViewModel {
    typealias UIKitView = TextView.UIKitTextView
    func createView() -> UIKitView {
        UIKitView.init().configured(self)
    }
    func createView(_ options: UIKitView.Options) -> UIKitView {
        UIKitView.init().configured(options).configured(self)
    }
    func createInnerView() -> UITextView {
        self.builder.makeUIView(coordinator: self.coordinator)
    }
}

// MARK: Configuration
extension TextView.UIKitTextView.ViewModel {
    func configured(_ delegate: TextViewUserInteractionProtocol?) -> Self {
        _ = self.coordinator.configure(delegate)
        return self
    }
}

// MARK: Updates
extension TextView.UIKitTextView.ViewModel {
    typealias Coordinator = TextView.UIKitTextView.Coordinator
    func updateUIView() {
        // do necessary updates here.
        // for example, we could call it after .text didSet
        // Or we could do it in UIView?
        // But...
        // we could update textView attributedString.
        // So, in this case we don't need to know about actual view.
    }
    // TODO: Move this method somewhere. This method is called when we need to update this view.
    func updateUIView(_ uiView: UITextView, coordinator: Coordinator) {
        // TODO: Add somewhere wholeTextKeeper
        // coordinator.updateWholeMarkStyle(uiView, wholeMarkStyleKeeper: self.wholeTextMarkStyleKeeper)
//        coordinator.updateWholeMarkStyle(<#T##view: UITextView##UITextView#>, wholeMarkStyleKeeper: <#T##TextView.MarkStyleKeeper#>)
    }
}
