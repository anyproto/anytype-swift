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
        
        // For OuterWorld.
        var onUpdate: PassthroughSubject<Update, Never> = .init()
        var onUpdateSubscription: AnyCancellable?
        private var builder: Builder = .init()
        private var coordinator: Coordinator = .init()
        
        init() {
            self.setup()
        }
        
        private func setup() {
            self.onUpdateSubscription = self.coordinator.$text.map(Update.text).subscribe(self.onUpdate)
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
    }
    func apply(update: Update) {
        // publish update?
        self.update = update
    }
}

// MARK: View
extension TextView.UIKitTextView.ViewModel {
    typealias UIKitView = TextView.UIKitTextView
    func createView() -> UIKitView {
        UIKitView.init().configured(self)
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
