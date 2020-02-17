//
//  TextBlocksViews+Base.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 01.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

extension TextBlocksViews {
    enum Base {
        class BlockViewModel: BlocksViews.Base.BlockViewModel {
            @Environment(\.developerOptions) var developerOptions
            private weak var delegate: TextBlocksViewsUserInteractionProtocol?
            
            private var textViewModel: TextView.UIKitTextView.ViewModel = .init()
            
            private var inputSubscriber: AnyCancellable?
            private var outputSubscriber: AnyCancellable?
            
            @Published var text: String { willSet { self.objectWillChange.send() } }
                    
            // MARK: Setup
            private func setupTextViewModel() {
                _ = self.textViewModel.configured(self)
                self.setupSubscribers()
            }
            private func setupSubscribers() {
                self.outputSubscriber = self.$text.map(TextView.UIKitTextView.ViewModel.Update.text).sink(receiveValue: self.textViewModel.apply(update:))
                self.inputSubscriber = self.textViewModel.onUpdate.sink(receiveValue: self.apply(update:))
            }
            private func setup() {
                if self.developerOptions.current.debug.enabled {
                    self.text = Self.debugString(self.developerOptions.current.workflow.mainDocumentEditor.textEditor.shouldHaveUniqueText, getID())
                    switch getBlock().type {
                    case let .text(blockType):
                        self.text = self.text + " >> " + blockType.text
                    default: return
                    }
                }
                else {
                    switch getBlock().type {
                    case let .text(blockType):
                        self.text = blockType.text
                    default: return
                    }
                }
                self.setupTextViewModel()
            }
            
            // MARK: Subclassing
            override init(_ block: Block) {
                self.text = ""
                super.init(block)
                self.setup()
            }
            
            private convenience init() {
                self.init(.mockText(.text))
            }
            
            // MARK: Subclassing accessors
            func getUIKitViewModel() -> TextView.UIKitTextView.ViewModel { self.textViewModel }
            
            override func makeUIView() -> UIView {
                self.getUIKitViewModel().createView()
            }
            
            // MARK: Empty
            static let empty = BlockViewModel.init()
        }
    }
}

// MARK: ViewModel / Apply to model.
extension TextBlocksViews.Base.BlockViewModel {
    private func setModelData(text: String) {
        let theText = self.text
        self.text = theText
        
        self.update { (block) in
            switch block.type {
                case let .text(value):
                    var value = value
                    value.text = text
                    block.type = .text(value)
                default: return
            }
        }
    }
    func apply(update: TextView.UIKitTextView.ViewModel.Update) {
        switch update {
        case .unknown: return
        case let .text(value): self.setModelData(text: value)
        }
    }
}

// MARK: TextBlocksViewsUserInteractionProtocolHolder
extension TextBlocksViews.Base.BlockViewModel: TextBlocksViewsUserInteractionProtocolHolder {
    func configured(_ delegate: TextBlocksViewsUserInteractionProtocol?) -> Self? {
        self.delegate = delegate
        return self
    }
}

// MARK: TextViewUserInteractionProtocol
extension TextBlocksViews.Base.BlockViewModel: TextViewUserInteractionProtocol {
    func didReceiveAction(_ action: TextView.UserAction) {
        self.delegate?.didReceiveAction(block: getBlock(), id: getID(), action: action)
    }
}

// MARK: Debug
extension TextBlocksViews.Base.BlockViewModel {
    // Class scope, actually.
    class func debugString(_ unique: Bool, _ id: Block.ID) -> String {
        unique ? self.defaultDebugStringUnique(id) : self.defaultDebugString()
    }
    class func defaultDebugStringUnique(_ id: Block.ID) -> String {
        self.defaultDebugString() + id.prefix(5)
    }
    class func defaultDebugString() -> String {
        .init("\(String(reflecting: self))".split(separator: ".").dropLast().last ?? "")
    }
}
