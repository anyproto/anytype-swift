import Foundation
import UIKit

struct GradientPoint {
    let start: CGPoint
    let end: CGPoint
}

extension GradientPoint {
    
    var identifier: String {
        "\(GradientPoint.self).\(start.identifier).\(end.identifier)"
    }
    
}

private extension CGPoint {
    
    var identifier: String {
        NSCoder.string(for: self)
    }
    
}
