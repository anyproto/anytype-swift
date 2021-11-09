import SwiftUI

struct CoverGradient: Identifiable, Codable, Equatable {
    let name: String
    
    let startHex: String
    let endHex: String
    
    var id: String {
        "\(name)\(startHex)\(endHex)"
    }
}

extension CoverGradient {
    
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
