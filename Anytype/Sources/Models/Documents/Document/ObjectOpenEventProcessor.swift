//
//  ObjectOpenEventProcessor.swift
//  Anytype
//
//  Created by Konstantin Mordan on 12.10.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import BlocksModels
import ProtobufMessages

enum ObjectOpenEventProcessor {
    
    static func fillRootModelWithEventData(
        rootModel: RootBlockContainer,
        event: ResponseEvent
    ) {
        let objectShowEvent = showEventsFromMessages(event.messages).first
        guard let objectShowEvent = objectShowEvent else { return }
        
        let rootId = objectShowEvent.rootID
        guard rootId.isNotEmpty else { return }
                
        let parsedBlocks = objectShowEvent.blocks.compactMap {
            BlockInformationConverter.convert(block: $0)
        }
        let parsedDetails = objectShowEvent.details.map {
            ObjectDetails(
                MiddlewareDetailsConverter.convertSetEvent($0)
            )
        }
        
        TreeBlockBuilder.buildBlocksTree(
            from: parsedBlocks,
            with: rootId,
            in: rootModel.blocksContainer
        )
        
        parsedDetails.forEach {
            rootModel.detailsStorage.add(details: $0, id: $0.id)
        }
    }
    
    private static func showEventsFromMessages(_ messages: [Anytype_Event.Message]) -> [Anytype_Event.Object.Show] {
        messages
            .compactMap { $0.value }
            .compactMap { value -> Anytype_Event.Object.Show? in
                guard case .objectShow(let event) = value else { return nil }
                return event
            }
    }
    
}
