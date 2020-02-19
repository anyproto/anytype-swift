//
//  BlockModel+Utilities.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 24.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation

// MARK: BlockModels
enum BlockModels {
    enum Utilities {}
}

extension BlockModels.Utilities {
    class Checker {
        static func compare(_ lhs: BusinessBlock?, _ rhs: BusinessBlock?) -> Bool {
            lhs?.indexPath == rhs?.indexPath
        }
    }
}

extension BlockModels.Utilities {
    class Inspector {
        enum BlockKind {
            // add unknown if needed.
            case block
            case meta
            static func inspect(_ element: BusinessBlock?) -> BlockKind? {
                Inspector.inspect(element)
            }
        }
        static func inspect(_ lhs: BusinessBlock?) -> BlockKind? {
            guard let lhs = lhs else { return nil }
            switch lhs {
            case is Block: return .block
            case is MetaBlock: return .meta
            default: return nil
            }
        }
        static func isNumbered(_ lhs: BlockModels.Block.RealBlock) -> Bool {
            switch (lhs.kind, lhs.information.content) {
            case let (.block, .text(value)) where value.contentType == .numbered: return true
            default: return false
            }
        }
        static func isNumberedList(_ lhs: BlockModels.Block.RealBlock) -> Bool {
            switch lhs.kind {
            case .meta where lhs.blocks.count > 0: return isNumbered(lhs.blocks[0] as! BlockModels.Block.RealBlock)
            default: return false
            }
        }
    }
}

extension BlockModels.Utilities {
    class IndexGenerator {
        static func generateID() -> BusinessBlock.Index {
            .init(item: Int.random(in: 1...100000), section: Int.random(in: 1...100000))
        }
        static func rootID() -> BusinessBlock.Index {
            .init(item: 0, section: 0)
        }
    }
}

extension BlockModels.Utilities {
    struct Debug {
        static let maxDotsRepeating = 10
        static func output(_ model: BlockModels.Block.RealBlock) -> [String] {
            let result = BlockModels.Transformer.FromTreeToListTransformer().toList(model)
            let output = result.map({ value -> String in
                let indentationLevel = value.indentationLevel()
                let section = value.indexPath.section
                let repeatingCount = min(Int(section), maxDotsRepeating)
                let indentation = Array(repeating: "..", count: repeatingCount).joined()
                let information = value.information.content
                return "\(indentation) -> \(value.indexPath) <- \(value.kind) | \(information)"
            })
            return output
        }
    }
}
