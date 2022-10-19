import Foundation
import SwiftUI

struct SmallButton: View {
    
    let icon: ImageAsset
    let text: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack() {
                Spacer.fixedWidth(8)
                Image(asset: icon).frame(width: 12, height: 12)
                Spacer.fixedWidth(4)
                AnytypeText(text, style: .caption1Medium, color: .textWhite)
                Spacer.fixedWidth(8)
            }
        }
        .frame(height: 28)
        .background(Color.System.amber100)
        .cornerRadius(6)
    }
}
