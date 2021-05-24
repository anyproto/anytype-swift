//
//  ButtonBlockActionHandler.swift
//  AnyType
//
//  Created by Denis Batvinkin on 17.02.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import BlocksModels


final class ButtonBlockActionHandler {
    private let service: BlockActionService

    init(service: BlockActionService) {
        self.service = service
    }

    func handlingButtonViewAction(_ block: BlockActiveRecordModelProtocol, _ action: TextBlockUserInteraction.ButtonView.UserAction) {
        switch action {
        case .toggle(.toggled):
            self.service.receiveOurEvents([.setToggled(.init(blockId: block.blockModel.information.id))])
        case .toggle(.insertFirst):
            if let defaultBlock = BlockBuilder.createDefaultInformation(block: block) {
                self.service.addChild(childBlock: defaultBlock, parentBlockId: block.blockModel.information.id)
            }
        case let .checkbox(value):
            service.checked(block: block, newValue: value)
        }
    }
}
