//
//  DeletionProgress.swift
//  Anytype
//
//  Created by Konstantin Mordan on 29.05.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import Foundation
import CoreGraphics

struct DeletionProgress: Equatable {
    
    // MARK: - Private vars
    
    private let deadline: Date
    
    // MARK: - Inititalizer
    
    init(deadline: Date) {
        self.deadline = deadline
    }
    
    // MARK: - Internal vars
    
    var daysToDeletion: Int {
        Calendar.current
            .numberOfDaysBetween(Date(), and: deadline)
            .clamped(0, Constants.maxDaysDeadline)
    }
}

extension DeletionProgress {
    
    enum Constants {
        static let maxDaysDeadline: Int = 30
    }
    
}
