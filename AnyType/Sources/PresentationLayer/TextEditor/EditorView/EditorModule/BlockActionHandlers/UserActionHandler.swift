//
//  UserActionHandler.swift
//  AnyType
//
//  Created by Denis Batvinkin on 17.02.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import BlocksModels

final class UserActionHandler {
    private let service: BlockActionService

    init(service: BlockActionService) {
        self.service = service
    }

    func handlingUserAction(_ block: BlockActiveRecordModelProtocol, _ action: BlocksViews.UserAction) {
        switch action {
        case let .specific(.file(.shouldUploadFile(value))):
            self.service.upload(block: block.blockModel.information, filePath: value.filePath)
        default: return
        }
    }
}
