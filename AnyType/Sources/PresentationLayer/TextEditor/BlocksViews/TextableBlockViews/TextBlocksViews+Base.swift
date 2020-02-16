//
//  TextBlocksViews+Base.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 01.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import SwiftUI

extension TextBlocksViews {
    enum Base {
        class BlockViewModel: BlocksViews.Base.BlockViewModel {
            @Environment(\.developerOptions) var developerOptions
            private weak var delegate: TextBlocksViewsUserInteractionProtocol?
            @Published var text: String {
                willSet {
                    self.objectWillChange.send()
                }
            }
            
            // TODO: Don't forget to replace by block.id!
                        
            override init(_ block: Block) {
                self.text = ""
                super.init(block)
                self.setup()
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
            }
            
            private convenience init() {
                self.init(.mockText(.text))
            }
            
            static let empty = BlockViewModel.init()
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
