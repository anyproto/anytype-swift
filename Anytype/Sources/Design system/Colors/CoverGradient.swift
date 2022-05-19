import SwiftUI

struct CoverGradientData: Identifiable, Codable, Equatable {
    let name: String
    let startHex: String
    let endHex: String
    
    var id: String { "\(name)\(startHex)\(endHex)" }
    
    // do not make var - SwiftUI glitches
    func asLinearGradient() -> some View {
        LinearGradient(
            gradient: Gradient(
                colors: [
                    Color(hex: self.startHex),
                    Color(hex: self.endHex)
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
            start: UIColor(hexString: data.startHex),
            end: UIColor(hexString: data.endHex)
        )
    }
    
    var data: CoverGradientData {
        switch self {
        case .sky:
            return CoverGradientData(name: "sky", startHex: "#6eb6e4", endHex: "#daeaf3")
        case .pinkOrange:
            return CoverGradientData(name: "pinkOrange", startHex: "#d8a4e1", endHex: "#ffcc81")
        case .greenOrange:
            return CoverGradientData(name: "greenOrange", startHex: "#63b3cb", endHex: "#f7c47a")
        case .bluePink:
            return CoverGradientData(name: "bluePink", startHex: "#73b7f0", endHex: "#f3bfac")
        case .yellow:
            return CoverGradientData(name: "yellow", startHex: "#ffb522", endHex: "#ecd91b")
        case .red:
            return CoverGradientData(name: "red", startHex: "#f55522", endHex: "#e51ca0")
        case .blue:
            return CoverGradientData(name: "blue", startHex: "#ab50cc", endHex: "#3e58eb")
        case .teal:
            return CoverGradientData(name: "teal", startHex: "#2aa7ee", endHex: "#0fc8ba")
        }
    }
}
