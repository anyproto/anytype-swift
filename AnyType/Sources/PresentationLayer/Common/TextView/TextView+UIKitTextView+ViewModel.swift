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

extension Namespace.ViewModel {
    struct Focus {
        typealias Position = TopLevel.FocusPosition
        var position: Position?
        
        /// We should call completion when we are done with set focus.
        var completion: (Bool) -> () = { _ in }
    }
}

extension Namespace.ViewModel {
    enum FirstResponder {
        enum Change {
            case unknown
            case become
            case resign
        }
    }
}

// UIView -> Coordinator -> Delegate -> ...
// UIView -> Coordinator.text -> ???
// UIView <- ViewModel <(Update)- ViewModel ( special model )
extension Namespace {
    class ViewModel {
        
        // For View
        @Published var update: Update = .unknown
        
        /// Interesting creature.
        /// We should store first value of `initial` view state.
        /// Instead, we separate `@Published update` property and `intentionalUpdatePublisher`.
        private var intentionalUpdateSubject: PassthroughSubject<Update?, Never> = .init()
        var intentionalUpdatePublisher: AnyPublisher<Update, Never> = .empty()
                
        /// Set focus subject and publishers.
        private var setFocusSubject: PassthroughSubject<Focus?, Never> = .init()
        var setFocusPublisher: AnyPublisher<Focus, Never> = .empty()
        
        // First Responder
        /// TODO: Remove when you are ready or do it in different way...
        /// We use this publisher for resign first responder if user press Multiaction on keyboard.
        /// Actually, we should do it without knowledge of first responder.
        /// So, we should resign first responder via AppDelegate.
        
        /// Deprecated.
        @available(iOS, introduced: 13.0, deprecated: 14.0, message: "This property makes sense only before first responder refactoring. Remove it when you are ready.")
        lazy private var shouldResignFirstResponderSubject: PassthroughSubject<Bool, Never> = .init()
        @available(iOS, introduced: 13.0, deprecated: 14.0, message: "This property makes sense only before first responder refactoring. Remove it when you are ready.")
        lazy private(set) var shouldResignFirstResponderPublisher: AnyPublisher<Bool, Never> = .empty()
        
        // For OuterWorld.
        /// First publisher which manipulates plain old string, text.
        /// Deprecated.
        lazy private(set) var updatePublisher: AnyPublisher<Update, Never> = .empty()
        
        /// Second publisher which manipulates rich string, attributed string.
        lazy private(set) var richUpdatePublisher: AnyPublisher<Update, Never> = .empty()
        lazy private(set) var auxiliaryPublisher: AnyPublisher<Update, Never> = .empty()
        
        /// Size publisher, we require it to update size of text views only if it has changed.
        lazy private(set) var sizePublisher: AnyPublisher<CGSize, Never> = .empty()
        
        /// ResignFirstResponder to outer world.
        private var firstResponderChangeSubject: PassthroughSubject<FirstResponder.Change, Never> = .init()
        private(set) var firstResponderChangePublisher: AnyPublisher<FirstResponder.Change, Never> = .empty()
        
        private(set) var coordinator: Coordinator = .init()
        
        /// Subscriptions
        private var firstResponderChangeSubscription: AnyCancellable?
        
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
            self.updatePublisher = self.coordinator.attributedTextPublisher.receive(on: DispatchQueue.global()).safelyUnwrapOptionals().map(\.string).map(Update.text).eraseToAnyPublisher()
            self.richUpdatePublisher = self.coordinator.attributedTextPublisher.receive(on: DispatchQueue.global()).safelyUnwrapOptionals().map(Update.attributedText).eraseToAnyPublisher()
        
            // Size
            self.sizePublisher = self.coordinator.textSizeChangePublisher
            
            // Should Resign First Responder
            self.shouldResignFirstResponderPublisher = self.shouldResignFirstResponderSubject.eraseToAnyPublisher()
            
            // Intentional Update
            self.intentionalUpdatePublisher = self.intentionalUpdateSubject.safelyUnwrapOptionals().eraseToAnyPublisher()
                        
            // SetFocusPublisher
            self.setFocusPublisher = self.setFocusSubject.safelyUnwrapOptionals().eraseToAnyPublisher()
            
            // FirstResponder
            self.firstResponderChangePublisher = self.firstResponderChangeSubject.eraseToAnyPublisher()
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

// MARK: Set Focus
extension Namespace.ViewModel {
    func set(focus: Focus?) {
        self.setFocusSubject.send(focus)
    }
}

// MARK: Resign first responder
extension Namespace.ViewModel {
    @available(iOS, introduced: 13.0, deprecated: 14.0, message: "This function makes sense only before first responder refactoring. Remove it when you are ready.")
    func shouldResignFirstResponder() {
        self.shouldResignFirstResponderSubject.send(true)
    }
    /// For view.
    /// TODO: Rethink.
    /// We need to listen `resignFirstResponder to deselect current state of selected text.
    private func didChangeFirstResponder(_ firstResponderChange: FirstResponder.Change) {
        self.firstResponderChangeSubject.send(firstResponderChange)
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
            var blockColor: UIColor?
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
}

// MARK: Configuration
extension Namespace.ViewModel {
    func configured(_ delegate: TextViewUserInteractionProtocol?) -> Self {
        _ = self.coordinator.configure(delegate)
        return self
    }

    func configured(firstResponderChangePublisher: AnyPublisher<FirstResponder.Change, Never>) -> Self {
        self.firstResponderChangeSubscription = firstResponderChangePublisher.sink(receiveValue: { [weak self] (value) in
            self?.didChangeFirstResponder(value)
        })
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
