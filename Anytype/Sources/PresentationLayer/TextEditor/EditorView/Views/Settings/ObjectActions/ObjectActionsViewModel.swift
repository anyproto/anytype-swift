//
//  ObjectActionsViewModel.swift
//  Anytype
//
//  Created by Denis Batvinkin on 24.09.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import Combine
import BlocksModels


final class ObjectActionsViewModel: ObservableObject {
    private let archiveService: ArchiveService

    @Published var details: DetailsDataProtocol = DetailsData.empty {
        didSet {
            objectActions = details.rawDetails.isEmpty ? [] : ObjectAction.allCasesWith(details: details)
        }
    }
    @Published var objectActions: [ObjectAction] = []

    init(objectId: String) {
        self.archiveService = ArchiveService(objectId: objectId)
    }

    func changeArchiveState() {
        let isArchived = details.isArchived ?? false
        archiveService.setArchive(!isArchived)
    }

    func favoriteObject() {
    }

    func moveTo() {
    }

    func template() {
    }

    func search() {
    }

}
