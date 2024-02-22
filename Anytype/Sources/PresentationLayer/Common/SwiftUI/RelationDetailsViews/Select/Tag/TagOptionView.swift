import SwiftUI

struct TagOptionView: View {
    let text: String
    let textColor: Color
    let backgroundColor: Color
    
    var body: some View {
        AnytypeText(text, style: .relation1Regular, color: textColor)
            .lineLimit(1)
            .padding(.horizontal, 6)
            .background(backgroundColor)
            .cornerRadius(3)
            .if(backgroundColor == Color.VeryLight.default) {
                $0.overlay(
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(Color.Shape.primary, lineWidth: 1)
                )
            }
            .frame(height: 20)
    }
}
