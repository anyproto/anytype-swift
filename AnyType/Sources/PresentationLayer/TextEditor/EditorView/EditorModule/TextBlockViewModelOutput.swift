//
//  TextBlockViewModelOutput.swift
//  AnyType
//
//  Created by Kovalev Alexander on 11.03.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import Foundation

/// Output for text block view model
protocol TextBlockViewModelOutput: class {
    
    /// Set text change closure to have ability invoke it later
    ///
    /// - Parameters:
    ///  - closure: Closure containing set text action
    func setTextChangeClosure(closure: @escaping() -> Void)
}
