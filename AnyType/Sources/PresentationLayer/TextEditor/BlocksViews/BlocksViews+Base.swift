//
//  BlocksViews+Base.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 13.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import SwiftUI

extension BlocksViews {
    enum Base {
        class BlockViewModel: ObservableObject {
            private var block: Block
            
            // MARK: Initialization
            init(_ block: Block) {
                self.block = block
            }
            
            // MARK: Subclass
            func getID() -> Block.ID { getBlock().id }
            func getBlock() -> Block { self.block }
            func update(block: (inout Block) -> ()) {
                self.block = self.update(self.block, body: block)
            }
            func makeSwiftUIView() -> AnyView { .init(Text("")) }
            func makeUIView() -> UIView { .init() }
            
            // MARK: Delegates
            
        }
    }
}

// MARK: Updates ( could be proposed in further releases ).
extension BlocksViews.Base.BlockViewModel {
    private func update<T>(_ value: T, body: (inout T) -> ()) -> T {
        var value = value
        body(&value)
        return value
    }
}

extension BlocksViews.Base.BlockViewModel: Identifiable {
    var id: Block.ID { getID() }
}

extension BlocksViews.Base.BlockViewModel: BlockViewBuilderProtocol {
    func buildView() -> AnyView { makeSwiftUIView() }
    func buildUIView() -> UIView { makeUIView() }
}
