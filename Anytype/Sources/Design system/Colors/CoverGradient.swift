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
            return CoverGradientData(name: "sky", startColor: .Gradients.Cover.skyStart, endColor: .Gradients.Cover.skyEnd)
        case .pinkOrange:
            return CoverGradientData(name: "pinkOrange", startColor: .Gradients.Cover.pinkOrangeStart, endColor: .Gradients.Cover.pinkOrangeEnd)
        case .greenOrange:
            return CoverGradientData(name: "greenOrange", startColor: .Gradients.Cover.greenOrangeStart, endColor: .Gradients.Cover.greenOrangeEnd)
        case .bluePink:
            return CoverGradientData(name: "bluePink", startColor: .Gradients.Cover.bluePinkStart, endColor: .Gradients.Cover.bluePinkEnd)
        case .yellow:
            return CoverGradientData(name: "yellow", startColor: .Gradients.Cover.yellowStart, endColor: .Gradients.Cover.yellowEnd)
        case .red:
            return CoverGradientData(name: "red", startColor: .Gradients.Cover.redStart, endColor: .Gradients.Cover.redEnd)
        case .blue:
            return CoverGradientData(name: "blue", startColor: .Gradients.Cover.blueStart, endColor: .Gradients.Cover.blueEnd)
        case .teal:
            return CoverGradientData(name: "teal", startColor: .Gradients.Cover.tealStart, endColor: .Gradients.Cover.tealEnd)
        }
    }
}
