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

protocol ArchiveServiceProtocol {
    func setArchive(_ isArchive: Bool)
}

final class ArchiveService: ArchiveServiceProtocol {
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
}

