//
//  BlocksModels+Utilities.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 15.06.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation

fileprivate typealias Namespace = BlocksModels

extension Namespace {
    enum Utilities {}
}

extension Namespace.Utilities {
    // TODO: Implement custom Debug for our models.
    enum Debug {
        static let maxDotsRepeating = 10
        static func output(_ model: BlocksModelsBlockModelProtocol) -> [String] {
            []
            // NOTE: Do not remove until you implement debug for all models.
            // It is example of fine output.
//            let result = BlockModels.Transformer.FromTreeToListTransformer().toList(model)
//            let output = result.map({ value -> String in
//                let indentationLevel = value.indentationLevel()
//                let section = value.indexPath.section
//                let repeatingCount = min(Int(section), maxDotsRepeating)
//                let indentation = Array(repeating: "..", count: repeatingCount).joined()
//                let information = value.information.content
//                return "\(indentation) -> \(value.indexPath) <- \(value.kind) | \(information)"
//            })
//            return output
        }
    }
}

extension Namespace.Utilities {
    enum InformationIdentifier {
        typealias Information = BlocksModelsInformationModelProtocolWithHashable
        
        struct Diffable<Wrapped: BlocksModelsInformationModelProtocolWithHashable>: Hashable {
            var value: Wrapped
        }
        
        static func identifier<T: Information>(for information: T) -> Diffable<T> {
            .init(value: information)
        }
    }
}
