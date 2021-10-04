//
//  EditorActionHandlerProtocol.swift
//  Anytype
//
//  Created by Konstantin Mordan on 04.10.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import BlocksModels

protocol EditorActionHandlerProtocol: AnyObject {
    func onEmptySpotTap()
    
    func upload(blockId: ActionHandlerBlockIdSource, filePath: String)
    
    func turnIntoPage(
        blockId: ActionHandlerBlockIdSource,
        completion: @escaping (BlockId?) -> ()
    )
    func showPage(blockId: ActionHandlerBlockIdSource)
    
    func handleAction(_ action: BlockHandlerActionType, blockId: BlockId)
    func handleActions(_ actions: [BlockHandlerActionType], blockId: BlockId)
    func handleActionForFirstResponder(_ action: BlockHandlerActionType)
}
