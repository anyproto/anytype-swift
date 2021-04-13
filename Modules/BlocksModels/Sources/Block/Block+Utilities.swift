import Foundation
import os

fileprivate typealias Namespace = Block
fileprivate typealias FileNamespace = Namespace.Utilities

public extension Namespace {
    enum Utilities {}
}

public extension FileNamespace {
    // TODO: Implement custom Debug for our models.
    enum Debug {
        static let maxDotsRepeating = 10
        public static func output(_ model: BlockModelProtocol) -> [String] {
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

public extension FileNamespace {
    enum IndexWalker {
        public typealias Model = BlockActiveRecordModelProtocol
        
        public static func model(beforeModel model: Model, includeParent: Bool, onlyFocused: Bool = true) -> Model? {
            guard let parent = model.findParent() else {
                
                assertionFailure("We don't have parent for model \(model.blockModel.information.id)")
                return nil
            }
            
            let id = model.blockModel.information.id
            let childrenIds = parent.childrenIds()
            
            guard let childIndex = childrenIds.firstIndex(where: {$0 == id}) else {
                assertionFailure("We can't find ourselves \(model.blockModel.information.id) in parent, so, skip it.")
                return nil
            }

            if childrenIds.startIndex == childIndex {
                // move to parent
                guard includeParent else { return nil }
                return self.model(beforeModel: parent, includeParent: includeParent, onlyFocused: onlyFocused)
            }
            else {
                let beforeIndex = childrenIds.index(before: childIndex)
                let beforeIndexId = childrenIds[beforeIndex]
                let chosen = parent.container?.choose(by: beforeIndexId)
                if onlyFocused {
                    guard let chosen = chosen else { return nil }
                    let information = chosen.blockModel.information
                    switch information.content {
                    /// Add support for title content type of Text.
                    case .text: return chosen
                    default: return self.model(beforeModel: chosen, includeParent: includeParent, onlyFocused: onlyFocused)
                    }
                }
                else {
                    return chosen
                }
            }
        }
    }
}

public extension FileNamespace {
    enum FirstResponderResolver {
        public typealias Model = BlockActiveRecordModelProtocol
        
        public static func resolvePendingUpdateIfNeeded(_ model: Model) {
            if model.isFirstResponder {
                self.resolvePendingUpdate(model)
            }
        }
        
        public static func resolvePendingUpdate(_ model: Model) {
            self.resolve(model)
        }
        
        private static func resolve(_ model: Model) {
            var model = model
            model.unsetFirstResponder()
            model.unsetFocusAt()
        }
    }
}

/// It is necessary to determine a kind of content in terms of something "Hashable and Equatable"
/// Actually, we could use `-> AnyHashable` type here as result type.
/// But it is fine to use `String` here.
public extension FileNamespace {
    enum ContentTypeIdentifier {
        public typealias Identifier = String

        private static func subIdentifier(_ content: BlockContent.Text) -> Identifier {
            switch content.contentType {
            case .title: return ".title"
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
            case .code: return ".code"
            }
        }

        public static func identifier(_ content: BlockContent) -> Identifier {
            switch content {
            case .smartblock(_): return ".smartblock"
            case let .text(value): return ".text" + self.subIdentifier(value)
            case .file(_): return ".file"
            case .divider(_): return ".divider"
            case .bookmark(_): return ".bookmark"
            case .link(_): return ".link"
            case .layout(_): return ".layout"
            }
        }
    }
}


public extension FileNamespace {
    /// The main purpose of this inspector is to identify kind of details.
    /// It could be done by parsing identifier of Information that was built from concrete detail.
    ///
    /// Prerequisites:
    ///
    /// 1. Build Information from Details.
    ///
    enum DetailsInspector {
        public typealias Kind = DetailsContent.Kind
        public typealias Id = BlockId
        public typealias Details = DetailsContent
        /// It parses identifier and try to figure our the kind of a detail.
        /// - Parameter id: Id of Information that is built from detail.
        /// - Returns: Kind of detail.
        ///
        public static func kind(of id: Id) -> Kind? {
            let (_, details) = BlockInformation.DetailsAsBlockConverter.IdentifierBuilder.asDetails(id)
            switch details {
            case Details.Title.id: return .title
            case Details.Emoji.id: return .iconEmoji
            default: return nil
            }
        }
    }
}
