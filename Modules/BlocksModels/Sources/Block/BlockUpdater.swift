import Foundation
import AnytypeCore

public final class BlockUpdater {
    
    private let container: BlockContainerModelProtocol

    public init(_ container: BlockContainerModelProtocol) {
        self.container = container
    }

    /// Insert block at position of an entry that is found by key.
    ///
    /// Notes
    /// If entry is not found, its all about implementaion how to handle this error.
    ///
    /// Warning
    /// It is complex action. It consists of two actions.
    /// 1. Add entry to container
    /// 2. Find correct place of this entry in a container.
    ///
    /// IF something goes wrong in second step, entry WILL be added to a container but we don't know about it place.
    ///
    /// - Parameters:
    ///   - block: A model that we would like to insert in our container.
    ///   - at: an associated key to an entry.
    public func insert(block: BlockModelProtocol, at: BlockId) {
        insert(block: block)
        
        container.add(child: block.information.id, beforeChild: at)
    }
    
    /// Like a method above, it do the same with the same warnings and notes.
    ///
    /// But it will insert entry AFTER an entry that could be found by associated key.
    ///
    /// - Parameters:
    ///   - block: A model that we would like to insert in our container.
    ///   - at: an associated key to an entry.
    public func insert(block: BlockModelProtocol, afterblock at: BlockId) {
        insert(block: block)
        
        container.add(child: block.information.id, afterChild: at)
    }
    
    /// Unlike other methods, this method only insert a model into a container.
    /// To build correct container, you should run method `buildTree` of a `BuilderProtocol` entry.
    /// - Parameter block: A model that we would like to insert in our container.
    public func insert(block: BlockModelProtocol) {
        container.add(block)
        /// When we store new page link block, we also need to add details information with identifier from this page link block
        /// Then we can update our page link block view, when details will be updated with .blockSetDetails event
        /// We receive this two events (blockAdd and blockSetDetails) in different messages
//        if case let .link(link) = block.information.content {
//            let blockId = link.targetBlockID
//            
//            let details = DetailsData(
//                rawDetails: [:],
//                blockId: blockId
//            )
//            
//            self.container.detailsContainer.add(
//                model: LegacyDetailsModel(detailsData: details),
//                id: blockId
//            )
//        }
    }

    /// Set new children to parent.
    /// It depends on implementation what exactly do children.
    /// For now we don't care about their new parent, it will be set after `buildTree` of a `BuilderProtocol` entry.
    /// - Parameters:
    ///   - children: new associated keys of children that will be set to parent.
    ///   - parent: an associated key to parent entry.
    public func set(children: [BlockId], parent: BlockId) {
        container.replace(
            childrenIds: children,
            parentId: parent,
            shouldSkipGuardAgainstMissingIds: true
        )
    }

    /// This is the only one valid way to update properties of entry.
    /// Do not try to update it somehow else, please.
    /// - Parameters:
    ///   - key: associated key to an entry that we would like to update.
    ///   - update: update-closure that we would like to apply to an entry.
    /// - Returns: Nothing, heh
    public func update(entry key: BlockId, update: @escaping (BlockModelProtocol) -> ()) {
        guard let entry = container.model(id: key) else {
            anytypeAssertionFailure("We haven't found an entry by key: \(key)", domain: .blockUpdater)
            return
        }
        
        update(entry)
    }
}
