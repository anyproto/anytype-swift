//
//  BlocksModels+Utilities.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 15.06.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import os

private extension Logging.Categories {
    static let blocksModelsIndexWalker: Self = "BlocksModels.Utilities.IndexWalker"
}

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

extension Namespace.Utilities {
    enum IndexWalker {
        typealias Model = BlocksModelsChosenBlockModelProtocol
        
        static func model(beforeModel model: Model, includeParent: Bool) -> Model? {
            guard let parent = model.findParent() else {
                // hm.. we don't have parent?
                let logger = Logging.createLogger(category: .blocksModelsIndexWalker)
                os_log(.debug, log: logger, "We don't have parent for model %@, so, we should return something?", "\(model.blockModel.information.id)")
                return nil
            }
            
            let id = model.blockModel.information.id
            let childrenIds = parent.childrenIds()
            
            guard let childIndex = childrenIds.firstIndex(where: {$0 == id}) else {
                // Heh, again, we can't find ourselves in parent.
                let logger = Logging.createLogger(category: .blocksModelsIndexWalker)
                os_log(.debug, log: logger, "We can't find ourselves (%@) in parent, so, skip it.", "\(model.blockModel.information.id)")
                return nil
            }

            if childrenIds.startIndex == childIndex {
                // move to parent
                guard includeParent else { return nil }
                return self.model(beforeModel: parent, includeParent: includeParent)
            }
            else {
                let beforeIndex = childrenIds.index(before: childIndex)
                let beforeIndexId = childrenIds[beforeIndex]
                return parent.container?.choose(by: beforeIndexId)
            }
        }
    }
}

extension Namespace.Utilities {
    enum FirstResponderResolver {
        typealias Model = BlocksModelsChosenBlockModelProtocol
        static func resolvePendingUpdate(_ model: Model) {
            model.container?.userSession.didChange()
        }
        static func resolve(_ model: Model) {
            if model.isFirstResponder {
                var model = model
                model.unsetFirstResponder()
                model.unsetFocusAt()
            }
        }
    }
}

/// It is necessary to determine a kind of content in terms of something "Hashable and Equatable"
/// Actually, we could use `-> AnyHashable` type here as result type.
/// But it is fine to use `String` here.
extension Namespace.Utilities {
    enum ContentTypeIdentifier {
        typealias Content = BlocksModels.Aliases.BlockContent
        typealias Identifier = String
        static private func subIdentifier(_ content: Content.Text) -> Identifier {
            switch content.contentType {
            case .text: return ".text"
            case .header: return ".header"
            case .header2: return ".header2"
            case .header3: return ".header3"
            case .header4: return ".header4"
            case .quote: return ".quote"
            case .checkbox: return ".checkbox"
            case .bulleted: return ".bulleted"
            case .numbered: return ".numbered"
            case .toggle: return ".toggle"
            case .callout: return ".callout"
            }
        }
        static func identifier(_ content: Content) -> Identifier {
            switch content {
            case .smartblock(_): return ".smartblock"
            case let .text(value): return ".text" + self.subIdentifier(value)
            case .file(_): return ".file"
            case .div(_): return ".div"
            case .bookmark(_): return ".bookmark"
            case .link(_): return ".link"
            }
        }
    }
}
