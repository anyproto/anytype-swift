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
        var position: BlockFocusPosition?
        
        /// We should call completion when we are done with set focus.
        var completion: (Bool) -> () = { _ in }
    }
}

extension Namespace.ViewModel {
    enum FirstResponder {
        enum Change {
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
        
        let coordinator: Coordinator
        
        /// Subscriptions
        private var firstResponderChangeSubscription: AnyCancellable?

        // Base block view model
        // TODO: Should be protocol instead of concrete block view model
        private weak var blockViewModel: BaseBlockViewModel?

        init(blockViewModel: BaseBlockViewModel) {
            self.blockViewModel = blockViewModel
            let factory = BlockRestrictionsFactory()
            let restrictions = factory.makeRestrictions(for: blockViewModel.information.content.type)
            let actionsHandler = BlockMenuActionsHandlerImp(marksPaneActionSubject: blockViewModel.marksPaneActionSubject, addBlockAndActionsSubject: blockViewModel.toolbarActionSubject)
            self.coordinator = Coordinator(menuItemsBuilder: BlockActionsBuilder(restrictions: restrictions),
                                           blockMenuActionsHandler: actionsHandler)

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
    
    func focusPosition() -> BlockFocusPosition? {
        coordinator.focusPosition()
    }
    func set(focus: Focus?) {
        self.setFocusSubject.send(focus)
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
            self?.blockViewModel?.becomeFirstResponder()
        })
        return self
    }
}

extension Namespace.ViewModel {
    typealias Coordinator = TextView.UIKitTextView.Coordinator
}
