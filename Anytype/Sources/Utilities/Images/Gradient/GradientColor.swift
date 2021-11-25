import Foundation
import UIKit
import SwiftUI

struct GradientColor: Hashable {
    let start: UIColor
    let end: UIColor
}

extension GradientColor {
    
    var identifier: String {
        "\(GradientColor.self).\(start.hexString).\(end.hexString)"
    }
       
    func asLinearGradient() -> some View {
        LinearGradient(
            gradient: Gradient(
                colors: [
                    start.suColor,
                    end.suColor
                ]
            ),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
}
