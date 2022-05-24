//
//  Debouncer.swift
//  Anytype
//
//  Created by Denis Batvinkin on 24.05.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import Foundation

final class Debouncer {
    private var workItem: DispatchWorkItem?

    deinit {
        workItem?.cancel()
    }

    func debounce(milliseconds: Int, action: @escaping () -> Void) {
        workItem?.cancel()

        let newWorkItem = DispatchWorkItem {
            action()
        }
        workItem = newWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(milliseconds), execute: newWorkItem)
    }

    func cancel() {
        workItem?.cancel()
    }
}
