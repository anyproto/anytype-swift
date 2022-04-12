//
//  TextIconPickerViewModel.swift
//  Anytype
//
//  Created by Dmitry Bilienko on 12.04.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import Foundation
import BlocksModels

final class TextIconPickerViewModel: ObjectIconPickerViewModelProtocol {
    let mediaPickerContentType: MediaPickerContentType = .images
    let isRemoveButtonAvailable: Bool = false

    let fileService: FileActionsServiceProtocol
    let textService: TextServiceProtocol
    let contextId: BlockId
    let objectId: BlockId

    init(
        fileService: FileActionsServiceProtocol,
        textService: TextServiceProtocol,
        contextId: BlockId,
        objectId: BlockId
    ) {
        self.fileService = fileService
        self.textService = textService
        self.contextId = contextId
        self.objectId = objectId
    }
    

    func setEmoji(_ emojiUnicode: String) {
        textService.setTextIcon(
            contextId: contextId,
            blockId: objectId,
            imageHash: "",
            emojiUnicode: emojiUnicode
        )
    }

    func uploadImage(from itemProvider: NSItemProvider) {

    }

    func removeIcon() { /* Unavailable */ }
}
