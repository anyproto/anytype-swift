//
//  TodoObjectIconImageGuidelineFactory.swift
//  TodoObjectIconImageGuidelineFactory
//
//  Created by Konstantin Mordan on 25.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import UIKit

enum TodoObjectIconImageGuidelineFactory {
    
    static func imageGuideline(for sizeGroup: ObjectIconImagePosition) -> ImageGuideline? {
        switch sizeGroup {
        case .openedObject:
            return Constants.x30
        case .dashboardList:
            return Constants.x18
        case .dashboardProfile:
            return nil
        case .dashboardSearch:
            return Constants.x18
        }
    }
    
}

private extension TodoObjectIconImageGuidelineFactory {
    
    enum Constants {
        static let x30 = ImageGuideline(
            size: CGSize(width: 28, height: 28),
            cornerRadius: 7,
            backgroundColor: UIColor.grayscaleWhite
        )
        
        static let x18 = ImageGuideline(
            size: CGSize(width: 18, height: 18),
            cornerRadius: 4,
            backgroundColor: UIColor.grayscaleWhite
        )
    }
}
