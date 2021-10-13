//
//  ToggleFlattener.swift
//  AnyType
//
//  Created by Kovalev Alexander on 25.03.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import BlocksModels

/// Flattener for toggle block
final class ToggleFlattener {
    
    private let shouldCheckToggleFlag: Bool
    
    /// Initializer
    init(shouldCheckToggleFlag: Bool = true) {
        self.shouldCheckToggleFlag = shouldCheckToggleFlag
    }
    
    /// Get children blocks
    ///
    /// - Parameters:
    ///   - id: Id of toggle block
    ///   - container: Container with blocks
    /// - Returns: Child block ids
    func processedChildren(
        _ id: BlockId,
        in blocksContainer: BlockContainerModelProtocol
    ) -> [BlockId] {
        if !shouldCheckToggleFlag {
            return blocksContainer.children(of: id)
        }
        let isToggled = UserSession.shared.toggles[id] ?? false
        if isToggled {
            return blocksContainer.children(of: id)
        }
        else {
            return []
        }
    }
}
