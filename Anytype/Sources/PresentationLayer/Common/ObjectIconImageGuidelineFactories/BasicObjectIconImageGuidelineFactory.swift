//
//  BasicObjectIconImageGuidelineFactory.swift
//  BasicObjectIconImageGuidelineFactory
//
//  Created by Konstantin Mordan on 25.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import UIKit

enum BasicObjectIconImageGuidelineFactory {
    
    func imageGuideline(for sizeGroup: ObjectIconImageSizeGroup) -> ImageGuideline? {
        switch sizeGroup {
        case .openedObject:
            return Constants.x96
        case .dashboardList:
            return Constants.x48
        case .dashboardProfile:
            return nil
        case .dashboardSearch:
            return Constants.x48
        }
    }
    
}

private extension BasicObjectIconImageGuidelineFactory {
    
    enum Constants {
        static let x96 = ImageGuideline(
            size: CGSize(width: 96, height: 96),
            cornerRadius: 4,
            backgroundColor: UIColor.grayscaleWhite
        )
        
        static let x48 = ImageGuideline(
            size: CGSize(width: 48, height: 48),
            cornerRadius: 2,
            backgroundColor: UIColor.grayscaleWhite
        )
    }
    
}
