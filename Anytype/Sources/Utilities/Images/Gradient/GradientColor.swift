import Foundation
import UIKit

struct GradientColor: Hashable {
    let start: UIColor
    let end: UIColor
}

extension GradientColor {
    
    var identifier: String {
        "\(GradientColor.self).\(start.hexString).\(end.hexString)"
    }
    
}
