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
import BlocksModels

fileprivate typealias Namespace = TextView.UIKitTextView

// UIView -> Coordinator -> Delegate -> ...
// UIView -> Coordinator.text -> ???
// UIView <- ViewModel <(Update)- ViewModel ( special model )
extension Namespace {
    class ViewModel {
        struct Focus {
            typealias Position = TopLevel.AliasesMap.FocusPosition
            var position: Position?
            
            /// We should call completion when we are done with set focus.
            var completion: (Bool) -> () = { _ in }
        }
        
        // For View
        @Published var update: Update = .unknown
        
        /// Interesting creature.
        /// We should store first value of `initial` view state.
        /// Instead, we separate `@Published update` property and `intentionalUpdatePublisher`.
        private var intentionalUpdateSubject: PassthroughSubject<Update?, Never> = .init()
        var intentionalUpdatePublisher: AnyPublisher<Update, Never> = .empty()
        
        // Set Focus
        @Published var setFocus: Focus?
        
        // First Responder
        private var shouldResignFirstResponderSubject: PassthroughSubject<Bool, Never> = .init()
        var shouldResignFirstResponderPublisher: AnyPublisher<Bool, Never> = .empty()
        
        // For OuterWorld.
        /// First publisher which manipulates plain old string, text.
        var updatePublisher: AnyPublisher<Update, Never> = .empty()
        
        /// Second publisher which manipulates rich string, attributed string.
        var richUpdatePublisher: AnyPublisher<Update, Never> = .empty()
        var auxiliaryPublisher: AnyPublisher<Update, Never> = .empty()
        var sizePublisher: AnyPublisher<CGSize, Never> = .empty()
        
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
            self.updatePublisher = self.coordinator.$text.receive(on: DispatchQueue.global()).safelyUnwrapOptionals().map(Update.text).eraseToAnyPublisher()
            self.richUpdatePublisher = self.coordinator.$attributedText.receive(on: DispatchQueue.global()).safelyUnwrapOptionals().map(Update.attributedText).eraseToAnyPublisher()
            self.auxiliaryPublisher = self.coordinator.$textAlignment.receive(on: DispatchQueue.global()).safelyUnwrapOptionals().map({Update.auxiliary(.init(textAlignment: $0))}).eraseToAnyPublisher()
        
            // Size
            self.sizePublisher = self.coordinator.$textSize.receive(on: RunLoop.main).safelyUnwrapOptionals().eraseToAnyPublisher()
            
            // First Responder
            self.shouldResignFirstResponderPublisher = self.shouldResignFirstResponderSubject.eraseToAnyPublisher()
            
            // Intentional Update
            self.intentionalUpdatePublisher = self.intentionalUpdateSubject.safelyUnwrapOptionals().eraseToAnyPublisher()
        }
        
        convenience init(_ delegate: TextViewUserInteractionProtocol?) {
            self.init()
            _ = self.configured(delegate)
        }
    }
}

// MARK: Intentional Update
extension Namespace.ViewModel {
    func intentional(update: Update?) {
        DispatchQueue.main.async {
            self.intentionalUpdateSubject.send(update)
        }
    }
}

// MARK: Resign first responder
extension Namespace.ViewModel {
    func shouldResignFirstResponder() {
        self.shouldResignFirstResponderSubject.send(true)
    }
}

// MARK: State
extension Namespace.ViewModel {
    enum Update {
        struct Payload {
            var attributedString: NSAttributedString
            var auxiliary: Auxiliary
        }
        struct Auxiliary {
            var textAlignment: NSTextAlignment
        }
        case unknown
        case text(String)
        case attributedText(NSAttributedString)
        case payload(Payload)
        case auxiliary(Auxiliary)
    }
    func apply(update: Update) {
        // publish update?
        self.update = update
    }
}

// MARK: View
extension Namespace.ViewModel {
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
extension Namespace.ViewModel {
    func configured(_ delegate: TextViewUserInteractionProtocol?) -> Self {
        _ = self.coordinator.configure(delegate)
        return self
    }
}

// MARK: Updates
extension Namespace.ViewModel {
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
