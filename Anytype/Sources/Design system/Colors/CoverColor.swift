import UIKit
struct CoverColorData: Identifiable, Codable, Equatable {
    let name: String
    let hex: String
    
    var id: String { "\(name)\(hex)" }
}

enum CoverColor: CaseIterable, Identifiable, Codable {
    case yellow
    case orange
    case red
    case pink
    case purple
    case blue
    case ice
    case teal
    case green
    case lightgrey
    case darkgrey
    case black
    
    var id: String { data.id }
    
    var uiColor: UIColor {
        UIColor(hexString: data.hex)
    }
    
    var data: CoverColorData {
        switch self {
        case .yellow:
            return CoverColorData(name: "yellow", hex: "#FBE885")
        case .orange:
            return CoverColorData(name: "orange", hex: "#F5B748")
        case .red:
            return CoverColorData(name: "red", hex: "#E46036")
        case .pink:
            return CoverColorData(name: "pink", hex: "#E6B1A4")
        case .purple:
            return CoverColorData(name: "purple", hex: "#611A36")
        case .blue:
            return CoverColorData(name: "blue", hex: "#376BE1")
        case .ice:
            return CoverColorData(name: "ice", hex: "#97CCEF")
        case .teal:
            return CoverColorData(name: "teal", hex: "#9FB0B6")
        case .green:
            return CoverColorData(name: "green", hex: "#336C45")
        case .lightgrey:
            return CoverColorData(name: "lightgrey", hex: "#DFDDD1")
        case .darkgrey:
            return CoverColorData(name: "darkgrey", hex: "#ACA998")
        case .black:
            return CoverColorData(name: "black", hex: "#2C2B28")
        }
    }
}
