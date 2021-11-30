//
//  DateExtension.swift
//  Anytype
//
//  Created by Konstantin Mordan on 30.11.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation

extension Date {

    static var yesterday: Date {
         Calendar.current.date(byAdding: .day, value: -1, to: Date())!
    }
    
    static var tomorrow: Date {
         Calendar.current.date(byAdding: .day, value: 1, to: Date())!
    }
    
}
