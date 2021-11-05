import SwiftUI

struct AnytypeGradient: Identifiable, Codable, Equatable {
    let name: String
    
    let startHex: String
    let endHex: String
    
    var id: String {
        "\(name)\(startHex)\(endHex)"
    }
}

extension AnytypeGradient {
    
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
