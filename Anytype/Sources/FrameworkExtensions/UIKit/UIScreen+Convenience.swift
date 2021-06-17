
import UIKit

extension UIScreen {
    
    var isFourInch: Bool {
        Self.main.bounds.size == Self.fourInchIphoneScreenSize
    }
    
    static var fourInchIphoneScreenSize: CGSize {
        CGSize(width: 320, height: 568)
    }
}
