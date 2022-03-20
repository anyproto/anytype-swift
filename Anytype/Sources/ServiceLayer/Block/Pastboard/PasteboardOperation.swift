//
//  PasteboardOperation.swift
//  Anytype
//
//  Created by Denis Batvinkin on 21.03.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import Foundation
import AnytypeCore

final class PasteboardOperation: AsyncOperation {

    // MARK: - Private variables

    private let pasteAction: (_ completion: @escaping () -> Void) -> Void

    // MARK: - Initializers

    init(pasteAction: @escaping (_ completion: @escaping () -> Void) -> Void) {
        self.pasteAction = pasteAction

        super.init()
    }

    override func start() {
        guard !isCancelled else {
            return
        }

        pasteAction { [weak self] in
            self?.state = .finished
        }

        state = .executing
    }
}
