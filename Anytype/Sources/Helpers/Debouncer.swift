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

    /// - Parameters:
    ///   - time: in milliseconds
    func debounce(time: Int, debounce_ action: @escaping () -> Void) {
        workItem?.cancel()

        let newWorkItem = DispatchWorkItem {
            action()
        }
        workItem = newWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(time), execute: newWorkItem)
    }

    func cancel() {
        workItem?.cancel()
    }
}
