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
        baseDocument: PartialBaseDocument,
        event: MiddlewareResponse
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
                id: $0.id,
                rawDetails: MiddlewareDetailsConverter.convertSetEvent($0)
            )
        }
        
        TreeBlockBuilder.buildBlocksTree(
            from: parsedBlocks,
            with: rootId,
            in: baseDocument.blocksContainer
        )
        
        parsedDetails.forEach {
            baseDocument.detailsStorage.add(details: $0, id: $0.id)
        }
        baseDocument.objectRestrictions = MiddlewareObjectRestrictionsConverter.convertObjectRestrictions(middlewareResctrictions: objectShowEvent.restrictions)
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
