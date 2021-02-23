//
//  ButtonBlockActionHandler.swift
//  AnyType
//
//  Created by Denis Batvinkin on 17.02.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import BlocksModels


final class ButtonBlockActionHandler {
    typealias ActionsPayloadTextViewButtonView = BlocksViews.New.Base.ViewModel.ActionsPayload.TextBlocksViewsUserInteraction.Action.ButtonViewUserAction

    private let service: BlockActionService

    init(service: BlockActionService) {
        self.service = service
    }

    func handlingButtonViewAction(_ block: BlockActiveRecordModelProtocol, _ action: ActionsPayloadTextViewButtonView) {
        switch action {
        case let .toggle(.toggled(value)):
            var block = block
            block.isToggled = value
        /// TODO:
        /// Configure event and send it.
        /// And send event that we need to recalculate all blocks below.
        /// Maybe it is "Toggle" event?
        case .toggle(.insertFirst):
            if let defaultBlock = BlockBuilder.createDefaultInformation(block: block) {
                self.service.addChild(childBlock: defaultBlock, parentBlockId: block.blockModel.information.id)
            }
        default: return
        }
    }
}
