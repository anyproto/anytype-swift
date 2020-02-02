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
        class BlockViewModel: BlockViewBuilderProtocol {
            private var block: Block
            private weak var userInteractionDelegate: TextBlocksViewsUserInteractionProtocol?
            @Published var text: String
            
            // TODO: Don't forget to replace by block.id!
            var id: Block.ID = UUID.init().uuidString
            
            init(_ block: Block) {
                self.block = block
                self.text = Self.defaultDebugString()
            }
            
            func buildView() -> AnyView {
                return .init(SwiftUI.Text(""))
            }
        }
    }
}

// MARK: Configuration
extension TextBlocksViews.Base.BlockViewModel {
    func configure(_ delegate: TextBlocksViewsUserInteractionProtocol?) -> Self {
        self.userInteractionDelegate = delegate
        return self
    }
}

// MARK: ObservableObject
extension TextBlocksViews.Base.BlockViewModel: ObservableObject {}

// MARK: Identifiable
extension TextBlocksViews.Base.BlockViewModel: Identifiable {}

// MARK: Debug
extension TextBlocksViews.Base.BlockViewModel {
    // Class scope, actually.
    class func defaultDebugString() -> String {
        .init("\(String(reflecting: self))".split(separator: ".").dropLast().last ?? "")
    }
}

// MARK: TextViewUserInteractionProtocol
extension TextBlocksViews.Base.BlockViewModel: TextViewUserInteractionProtocol {
    func didReceiveAction(_ action: TextView.UserAction) {
        self.userInteractionDelegate?.didReceiveAction(block: block, id: id, action: action)
    }
}
