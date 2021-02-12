//
//  TimeChecker.swift
//  AnyType
//
//  Created by Kovalev Alexander on 11.02.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import QuartzCore

/// Entity which helps to make a debounce in case your don't use Combine
final class TimeChecker {
    private var previous: CFTimeInterval?
    private let threshold: CFTimeInterval
    
    /// Initializator
    ///
    /// - Parameters:
    ///   - threshold: Time interval which will be checked during exceedsTimeInterval method calls
    init(threshold: CFTimeInterval) {
        self.threshold = threshold
    }
    
    /// Returns true in case of time interval (threshold) has beed exceeded from last time calling this method, otherwise return false
    func exceedsTimeInterval() -> Bool {
        if let previous = self.previous, CACurrentMediaTime() - previous < self.threshold {
            return false
        }
        else {
            self.previous = CACurrentMediaTime()
            return true
        }
    }
}
