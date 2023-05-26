import Foundation
import UIKit

struct AnytypeDismiss {
    
    let dismiss: () -> Void
    
    func callAsFunction() {
        dismiss()
    }
}
