import SwiftUI

struct CoverGradientData: Identifiable {
    let name: String
    let startColor: Color
    let endColor: Color
    
    var id: String { "\(name)\(startColor)\(endColor)" }
    
    // do not make var - SwiftUI glitches
    func asLinearGradient() -> some View {
        LinearGradient(
            gradient: Gradient(
                colors: [
                    startColor,
                    endColor
                ]
            ),
            startPoint: .top,
            endPoint: .bottom
        )
    }
}


enum CoverGradient: CaseIterable, Identifiable, Codable {
    case sky
    case pinkOrange
    case greenOrange
    case bluePink
    case yellow
    case red
    case blue
    case teal
    
    var id: String { data.id }
    
    var gradientColor: GradientColor {
        GradientColor(
            start: UIColor(data.startColor),
            end: UIColor(data.endColor)
        )
    }
    
    var data: CoverGradientData {
        switch self {
        case .sky:
            return CoverGradientData(name: "sky", startColor: .Gradients.skyStart, endColor: .Gradients.skyEnd)
        case .pinkOrange:
            return CoverGradientData(name: "pinkOrange", startColor: .Gradients.pinkOrangeStart, endColor: .Gradients.pinkOrangeEnd)
        case .greenOrange:
            return CoverGradientData(name: "greenOrange", startColor: .Gradients.greenOrangeStart, endColor: .Gradients.greenOrangeEnd)
        case .bluePink:
            return CoverGradientData(name: "bluePink", startColor: .Gradients.bluePinkStart, endColor: .Gradients.bluePinkEnd)
        case .yellow:
            return CoverGradientData(name: "yellow", startColor: .Gradients.yellowStart, endColor: .Gradients.yellowEnd)
        case .red:
            return CoverGradientData(name: "red", startColor: .Gradients.redStart, endColor: .Gradients.redEnd)
        case .blue:
            return CoverGradientData(name: "blue", startColor: .Gradients.blueStart, endColor: .Gradients.blueEnd)
        case .teal:
            return CoverGradientData(name: "teal", startColor: .Gradients.tealStart, endColor: .Gradients.tealEnd)
        }
    }
}
