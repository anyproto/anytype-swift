import Foundation
import SwiftUI

struct SmallButton: View {
    
    let icon: ImageAsset
    let text: String
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack() {
                Spacer.fixedWidth(8)
                Image(asset: icon).frame(width: 12, height: 12)
                Spacer.fixedWidth(4)
                AnytypeText(text, style: .caption1Medium, color: .Text.white)
                Spacer.fixedWidth(8)
            }
            .frame(height: 28)
            .background(isActive ? Color.System.amber100 : Color.Button.inactive)
            .cornerRadius(6)
        }
        .buttonStyle(ShrinkingButtonStyle())
        .disabled(!isActive)
    }
}
