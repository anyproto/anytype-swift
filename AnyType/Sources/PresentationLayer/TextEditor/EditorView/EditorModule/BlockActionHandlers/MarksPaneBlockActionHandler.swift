//
//  MarksPaneBlockActionHandler.swift
//  AnyType
//
//  Created by Denis Batvinkin on 17.02.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import BlocksModels


final class MarksPaneBlockActionHandler {
    typealias ActionsPayload = BlocksViews.New.Base.ViewModel.ActionsPayload
    typealias ActionsPayloadMarksPane = ActionsPayload.MarksPaneHolder.Action

    private let service: BlockActionService

    init(service: BlockActionService) {
        self.service = service
    }
    
    func handlingMarksPaneAction(_ block: BlockActiveRecordModelProtocol, _ action: ActionsPayloadMarksPane) {
        switch action {
        case let .backgroundColor(_, action):
            switch action {
            case let .setColor(value):
                /// Do stuff..
                self.service.setBackgroundColor(block: block.blockModel.information, color: value)
            }
        default: return
        }
    }
}
