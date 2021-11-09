import Foundation
import UIKit
import AnytypeCore
import SwiftUI

enum AnytypeColor: String {
    
    // MARK: - Pure colors
    
    case pureLemon
    case pureAmber
    case pureRed
    case purePink
    case purePurple
    case pureUltramarine
    case pureBlue
    case pureTeal
    case pureGreen
    
    // MARK: - Dark colors
    
    case darkLemon
    case darkAmber
    case darkRed
    case darkPink
    case darkPurple
    case darkUltramarine
    case darkBlue
    case darkTeal
    case darkGreen
    case darkColdGray
    
    // MARK: - Light colors
    
    case lightLemon
    case lightAmber
    case lightRed
    case lightPink
    case lightPurple
    case lightUltramarine
    case lightBlue
    case lightTeal
    case lightGreen
    case lightColdGray
    
    // MARK: - Text colors
    
    case textPrimary
    case textSecondary
    case textTertiary
    
    // MARK: - Grayscale
    
    case grayscaleWhite
    case grayscale90
    case grayscale70
    case grayscale50
    case grayscale30
    case grayscale10
    
}

extension AnytypeColor {
    
    var asUIColor: UIColor {
        guard let color = UIColor(named: self.rawValue) else {
            anytypeAssertionFailure("No color named: \(self.rawValue)")
            return .grayscale90
        }
        
        return color
    }
    
    var asColor: Color {
        Color(self.rawValue)
    }
    
}
