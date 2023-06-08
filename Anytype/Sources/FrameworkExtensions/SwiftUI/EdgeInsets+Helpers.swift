import Foundation
import SwiftUI

extension EdgeInsets {
    
    init(side: CGFloat) {
        self.init(top: side, leading: side, bottom: side, trailing: side)
    }
    
    init(horizontal: CGFloat, vertical: CGFloat) {
        self.init(top: vertical, leading: horizontal, bottom: vertical, trailing: horizontal)
    }
}
