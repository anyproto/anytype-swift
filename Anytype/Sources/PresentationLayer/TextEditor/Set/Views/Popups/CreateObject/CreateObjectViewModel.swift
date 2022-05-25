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
    private let relationService: RelationsServiceProtocol
    private let debouncer = Debouncer()
    private let openToEditAction: () -> Void
    private let closeAction: () -> Void
    private var currentText: String = .empty

    init(relationService: RelationsServiceProtocol,
         openToEditAction: @escaping () -> Void,
         closeAction: @escaping () -> Void) {
        self.relationService = relationService
        self.openToEditAction = openToEditAction
        self.closeAction = closeAction
    }
    
    func textDidChange(_ text: String) {
        currentText = text

        debouncer.debounce(milliseconds: 100) { [weak self] in
            guard let self = self else { return }

            self.relationService.updateRelation(relationKey: BundledRelationKey.name.rawValue, value: text.protobufValue)
        }
    }

    func openToEditAction(with text: String) {
        debouncer.cancel()
        
        if currentText != text {
            relationService.updateRelation(relationKey: BundledRelationKey.name.rawValue, value: text.protobufValue)
        }
        openToEditAction()
    }

    func returnDidTap() {
        closeAction()
    }
}
