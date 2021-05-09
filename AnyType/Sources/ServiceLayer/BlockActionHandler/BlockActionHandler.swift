//
//  BlockActionHandler.swift
//  AnyType
//
//  Created by Denis Batvinkin on 05.05.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import UIKit
import BlocksModels


// MARK: - Action Type

extension BlockActionHandler {
    /// Action on style view
    enum ActionType: Hashable {
        case turnInto(BlockContent.Text.ContentType)

        case setTextColor(UIColor)
        case setBackgroundColor(UIColor)

        case selecTextColor(UIColor)
        case selecBackgroundColor(UIColor)

        case setBoldStyle
        case setItalicStyle
        case setStrikethroughStyle
        case setKeyboardStyle

        case setLeftAlignment
        case setCenterAlignment
        case setRightAlignment

        case setLink(String)
    }
}

// MARK: - BlockActionHandler

/// Actions from block
class BlockActionHandler {
    typealias Completion = (BlockActionService.Reaction.ActionType?, EventListening.PackOfEvents) -> Void

    private let service: BlockActionService

    // MARK: - Lifecycle

    init?(documentId: String?) {
        guard let documentId = documentId else { return nil }
        self.service = .init(documentId: documentId)
    }

    // MARK: - Public methods

    func handleBlockAction(_ action: ActionType, block: BlockModelProtocol, completion: @escaping Completion) {
        service.configured { actionType, events in
            completion(actionType, events)
        }

        switch action {
        case let .turnInto(textStyle):
            let textBlockContentType: BlockContent = .text(BlockContent.Text(contentType: textStyle))
            service.turnInto(block: block.information, type: textBlockContentType, shouldSetFocusOnUpdate: false)
        default:
            assertionFailure("Action has not implemented yet \(String(describing: action))")
        }
    }
}
