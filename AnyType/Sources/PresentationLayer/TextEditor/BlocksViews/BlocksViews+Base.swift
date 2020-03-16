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
        class ViewModel: ObservableObject {
            typealias BlockModel = BlockModels.Block.RealBlock
            typealias BlockModelReal = BlockModels.Block.RealBlock // has type .block
            typealias BlockModelID = BlockModels.Block.RealBlock.Index
            
            private var block: BlockModel
            
            // MARK: Initialization
            init(_ block: BlockModel) {
                self.block = block
            }

            static func generateID() -> BlockModelID {
                BlockModels.Utilities.IndexGenerator.generateID()
            }
            
            // MARK: Subclass / Blocks
            func getID() -> BlockModelID { getBlock().indexPath }
            
            /// Discussion
            /// This function should return full index and convert it in two numbers.
            /// Hahaha.
            func getFullIndex() -> BlockModelID {
                let block = getBlock()
                return block.indexPath
            }
            func getBlock() -> BlockModel { block }
            func isRealBlock() -> Bool { block.kind == .block }
            func getRealBlock() -> BlockModelReal { block }
            func update(block: (inout BlockModelReal) -> ()) {
                if isRealBlock() {
                    self.block = update(getRealBlock(), body: block)
                }
            }
            
            // MARK: Indentation
            func indentationLevel() -> UInt {
                self.getBlock().indentationLevel()
                //getID().section > 0 ? UInt(getID().section) : 0
            }
            
            // MARK: Subclass / Information
            var information: MiddlewareBlockInformationModel { block.information }
            
            // MARK: Subclass / Views
            func makeSwiftUIView() -> AnyView { .init(Text("")) }
            func makeUIView() -> UIView { .init() }
        }
    }
}

// MARK: Updates ( could be proposed in further releases ).
extension BlocksViews.Base.ViewModel {
    private func update<T>(_ value: T, body: (inout T) -> ()) -> T {
        var value = value
        body(&value)
        return value
    }
}

extension BlocksViews.Base.ViewModel: Identifiable {}

extension BlocksViews.Base.ViewModel: BlockViewBuilderProtocol {
    var blockId: BlockID { getRealBlock().information.id }
    
    var id: IndexID { getID() }
    
    func buildView() -> AnyView { makeSwiftUIView() }
    func buildUIView() -> UIView { makeUIView() }
}

// MARK: Holder
protocol BlocksViewsViewModelHolder {
    typealias ViewModel = BlocksViews.Base.ViewModel
    var ourViewModel: BlocksViews.Base.ViewModel { get }
}

extension BlocksViews.Base {
    enum Utilities {}
}
