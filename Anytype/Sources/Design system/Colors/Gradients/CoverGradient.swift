import SwiftUI

struct CoverGradientData: Identifiable, Equatable {
    let name: String
    let startColor: Color
    let endColor: Color
    
    var id: String { "\(name)\(startColor)\(endColor)" }
}

struct CoverGradientView: View, Equatable {
    
    let data: CoverGradientData
    
    var body: some View {
        LinearGradient(
            gradient: Gradient(
                colors: [
                    data.startColor,
                    data.endColor
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
            return CoverGradientData(name: "sky", startColor: .CoverGradients.skyStart, endColor: .CoverGradients.skyEnd)
        case .pinkOrange:
            return CoverGradientData(name: "pinkOrange", startColor: .CoverGradients.pinkOrangeStart, endColor: .CoverGradients.pinkOrangeEnd)
        case .greenOrange:
            return CoverGradientData(name: "greenOrange", startColor: .CoverGradients.greenOrangeStart, endColor: .CoverGradients.greenOrangeEnd)
        case .bluePink:
            return CoverGradientData(name: "bluePink", startColor: .CoverGradients.bluePinkStart, endColor: .CoverGradients.bluePinkEnd)
        case .yellow:
            return CoverGradientData(name: "yellow", startColor: .CoverGradients.yellowStart, endColor: .CoverGradients.yellowEnd)
        case .red:
            return CoverGradientData(name: "red", startColor: .CoverGradients.redStart, endColor: .CoverGradients.redEnd)
        case .blue:
            return CoverGradientData(name: "blue", startColor: .CoverGradients.blueStart, endColor: .CoverGradients.blueEnd)
        case .teal:
            return CoverGradientData(name: "teal", startColor: .CoverGradients.tealStart, endColor: .CoverGradients.tealEnd)
        }
    }
}
