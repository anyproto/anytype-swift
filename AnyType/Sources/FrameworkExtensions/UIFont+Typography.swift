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
    private static let interRegular = "Inter-Regular"
    private static let interBold = "Inter-Bold"
    
    static var titleFont: UIFont {
        UIFont(name: graphikLCGSemibold, size: 34) ?? .preferredFont(forTextStyle: .largeTitle)
    }
    
    static var header1Font: UIFont {
        UIFont(name: graphikLCGSemibold, size: 28) ?? .preferredFont(forTextStyle: .title1)
    }
    
    static var header2Font: UIFont {
        UIFont(name: graphikLCGSemibold, size: 22) ?? .preferredFont(forTextStyle: .title2)
    }
    
    static var header3Font: UIFont {
        UIFont(name: interBold, size: 17) ?? .preferredFont(forTextStyle: .title3)
    }
    
    static var highlightFont: UIFont {
        UIFont(name: interRegular, size: 17) ?? .preferredFont(forTextStyle: .headline)
    }
    
    static var bodyFont: UIFont {
        UIFont(name: interRegular, size: 15) ?? .preferredFont(forTextStyle: .body)
    }
}
