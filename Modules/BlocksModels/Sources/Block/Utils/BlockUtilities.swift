import Foundation
import os

// TODO: Implement custom Debug for our models.
enum BlockDebug {
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

enum BlockIndexWalker {
    public static func model(
        beforeModel model: BlockActiveRecordModelProtocol,
        includeParent: Bool,
        onlyFocused: Bool = true
    ) -> BlockActiveRecordModelProtocol? {
        guard let parent = model.findParent() else {
            
            assertionFailure("We don't have parent for model \(model.blockId)")
            return nil
        }
        
        let id = model.blockId
        let childrenIds = parent.childrenIds()
        
        guard let childIndex = childrenIds.firstIndex(where: {$0 == id}) else {
            assertionFailure("We can't find ourselves \(model.blockId) in parent, so, skip it.")
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

enum BlockFirstResponderResolver {
    public static func resolvePendingUpdateIfNeeded(_ model: BlockActiveRecordModelProtocol) {
        if model.isFirstResponder {
            self.resolvePendingUpdate(model)
        }
    }
    
    public static func resolvePendingUpdate(_ model: BlockActiveRecordModelProtocol) {
        self.resolve(model)
    }
    
    private static func resolve(_ model: BlockActiveRecordModelProtocol) {
        var model = model
        model.unsetFirstResponder()
        model.unsetFocusAt()
    }
}
