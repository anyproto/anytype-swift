//
//  ArchiveService.swift
//  Anytype
//
//  Created by Denis Batvinkin on 24.09.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import ProtobufMessages
import Combine
import BlocksModels

protocol SimpleObjectActionsServiceProtocol {
    func setArchive(_ isArchive: Bool)
    func setFavorite(_ isFavorite: Bool)
}

final class SimpleObjectActionsService: SimpleObjectActionsServiceProtocol {
    private var subscriptions = [AnyCancellable]()
    private var objectId: String

    init(objectId: String) {
        self.objectId = objectId
    }

    func setArchive(_ isArchive: Bool) {
        Anytype_Rpc.Object.SetIsArchived.Service.invoke(contextID: objectId, isArchived: isArchive, queue: .global())
            .receiveOnMain()
            .sinkWithDefaultCompletion("SetIsArchived") { response in
            }
            .store(in: &subscriptions)
    }

    func setFavorite(_ isFavorite: Bool) {
        Anytype_Rpc.Object.SetIsFavorite.Service.invoke(contextID: objectId, isFavorite: isFavorite, queue: .global())
            .receiveOnMain()
            .sinkWithDefaultCompletion("SetIsArchived") { response in
            }
            .store(in: &subscriptions)
    }
}

