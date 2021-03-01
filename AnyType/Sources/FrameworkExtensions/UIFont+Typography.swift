//
//  UIFont+Typography.swift
//  AnyType
//
//  Created by Kovalev Alexander on 26.02.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import UIKit

extension UIFont {
    private static let graphikLCGSemibold = "GraphikLCG-Semibold"
    
    static var titleFont: UIFont {
        UIFont(name: graphikLCGSemibold, size: 34) ?? .preferredFont(forTextStyle: .title1)
    }
}
