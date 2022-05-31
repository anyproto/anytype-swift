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
    private let pasteboardMiddlewareService: PasteboardMiddlewareServiceProtocol
    private let completion: (PasteboardPasteResult?) -> Void

    // MARK: - Initializers

    init(itemProvider: NSItemProvider,
         context: PasteboardActionContext,
         pasteboardMiddlewareService: PasteboardMiddlewareServiceProtocol,
         completion: @escaping (PasteboardPasteResult?) -> Void) {
        self.itemProvider = itemProvider
        self.context = context
        self.pasteboardMiddlewareService = pasteboardMiddlewareService
        self.completion = completion

        super.init()
    }

    override func start() {
        guard !isCancelled else {
            self.state = .finished
            return
        }

        itemProvider.loadFileRepresentation(
            forTypeIdentifier: UTType.data.identifier
        ) { [weak self] temporaryUrl, error in
            self?.loadItemProviderCompletion(temporaryUrl: temporaryUrl, error: error)
        }

        state = .executing
    }

    private func loadItemProviderCompletion(temporaryUrl: URL?, error: Error?) {
        guard let temporaryUrl = temporaryUrl?.relativePath else {
            state = .finished
            return
        }

        let result = pasteboardMiddlewareService.pasteFile(localPath: temporaryUrl,
                                                           name: itemProvider.suggestedName ?? "",
                                                           context: context)
        completion(result)
        state = .finished
    }
}
