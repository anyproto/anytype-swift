import Foundation
import UIKit

struct GradientColor {
    let start: UIColor
    let end: UIColor
}

extension GradientColor {
    
    var identifier: String {
        "\(GradientColor.self).\(start.hexString).\(end.hexString)"
    }
    
}
