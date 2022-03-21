//
//  PasteboardFileOperation.swift
//  Anytype
//
//  Created by Denis Batvinkin on 21.03.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import AnytypeCore
import UniformTypeIdentifiers

final class PasteboardFileOperation: AsyncOperation {

    // MARK: - Private variables

    private let itemProvider: NSItemProvider
    private let context: PasteboardActionContext
    private weak var pasteActionDelegate: PasteboardSlotActionDelegate?

    // MARK: - Initializers

    init(itemProvider: NSItemProvider, context: PasteboardActionContext, pasteActionDelegate: PasteboardSlotActionDelegate?) {
        self.itemProvider = itemProvider
        self.context = context
        self.pasteActionDelegate = pasteActionDelegate

        super.init()
    }

    override func start() {
        guard !isCancelled else {
            return
        }

        itemProvider.loadFileRepresentation(
            forTypeIdentifier: UTType.data.identifier
        ) { [weak self] temporaryUrl, error in
            guard let self = self else { return }

            guard let temporaryUrl = temporaryUrl?.relativePath else {
                self.state = .finished
                return
            }

            self.pasteActionDelegate?.pasteFile(localPath: temporaryUrl, name: self.itemProvider.suggestedName ?? "", context: self.context)
            self.state = .finished
        }

        state = .executing
    }
}
