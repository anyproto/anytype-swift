//
//  UserActionHandler.swift
//  AnyType
//
//  Created by Denis Batvinkin on 17.02.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import BlocksModels

final class UserActionHandler {
    typealias ActionsPayload = BlocksViews.New.Base.ViewModel.ActionsPayload
    typealias ActionsPayloadUserAction = ActionsPayload.UserActionHolder.Action

    private let service: BlockActionService

    init(service: BlockActionService) {
        self.service = service
    }

    func handlingUserAction(_ block: BlockActiveRecordModelProtocol, _ action: ActionsPayloadUserAction) {
        switch action {
        case let .specific(.file(.file(.shouldUploadFile(value)))):
            self.service.upload(block: block.blockModel.information, filePath: value.filePath)
        case let .specific(.file(.image(.shouldUploadImage(value)))):
            self.service.upload(block: block.blockModel.information, filePath: value.filePath)
        default: return
        }
    }
}
