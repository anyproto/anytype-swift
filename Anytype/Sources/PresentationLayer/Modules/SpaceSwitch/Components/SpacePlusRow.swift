import Foundation
import SwiftUI

struct SpacePlusRow: View {
    
    let loading: Bool
    let onTap: () -> Void
    
    var body: some View {
        ZStack {
            if loading {
                DotsView()
                    .fixedSize()
            } else {
                Image(asset: .X32.plus)
            }
        }
        .frame(width: 96, height: 96)
        .foregroundColor(.Text.white)
        .background(.white.opacity(0.2))
        .cornerRadius(8, style: .continuous)
        .onTapGesture {
            if !loading {
                onTap()
            }
        }
    }
}
