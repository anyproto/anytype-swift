import Foundation
import SwiftUI

struct SpacePlusRow: View {
    
    let onTap: () -> Void
    
    var body: some View {
        Image(asset: .X32.plus)
            .frame(width: 96, height: 96)
            .foregroundColor(.Text.white)
            .background(.white.opacity(0.2))
            .spaceIconCornerRadius()
            .onTapGesture {
                onTap()
            }
    }
}
