//
//  BlockActionHandlerProtocol.swift
//  Anytype
//
//  Created by Konstantin Mordan on 04.10.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import BlocksModels

protocol BlockActionHandlerProtocol {
    typealias Completion = (PackOfEvents) -> Void
    
    func upload(blockId: BlockId, filePath: String)
    func turnIntoPage(blockId: BlockId, completion: @escaping (BlockId?) -> ())
    
    func handleBlockAction(
        _ action: BlockHandlerActionType,
        blockId: BlockId,
        completion: Completion?
    )
}
