//
//  CreateObjectViewModel.swift
//  Anytype
//
//  Created by Denis Batvinkin on 24.05.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import BlocksModels
import AnytypeCore

final class CreateObjectViewModel {
    private var relationService: RelationsServiceProtocol

    init(relationService: RelationsServiceProtocol) {
        self.relationService = relationService
    }

    func textDidChange(_ text: String) {
        relationService.updateRelation(relationKey: BundledRelationKey.name.rawValue, value: text.protobufValue)
    }
}
