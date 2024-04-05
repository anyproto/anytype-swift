import Foundation
import SwiftUI
import AnytypeCore

struct CircleGradientView: View {
    
    private let storage = IconGradientStorage()
    private let gradientInfo: IconGradient
        
    init(gradientId: GradientId) {
        self.gradientInfo = storage.gradient(for: gradientId.rawValue)
    }
    
    var body: some View {
        GeometryReader { reader in
            RadialGradient(
                colors: [
                    gradientInfo.centerColor.suColor,
                    gradientInfo.roundColor.suColor
                ],
                center: .center,
                startRadius: 0,
                endRadius: reader.size.width * 0.5
            )
            .clipShape(Circle())
        }
    }
}
