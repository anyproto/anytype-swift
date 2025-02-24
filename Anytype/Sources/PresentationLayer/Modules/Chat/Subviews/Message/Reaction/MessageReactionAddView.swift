import Foundation
import SwiftUI

struct MessageReactionAddView: View {
    
    let position: MessageHorizontalPosition
    let onTap: () -> Void
    
    var body: some View {
        Button {
            onTap()
        } label: {
            Image(asset: .X24.reaction)
                .foregroundStyle(Color.Control.button)
                .frame(width: 28, height: 28)
                .background(Color.Shape.transperentSecondary)
                .cornerRadius(16, style: .circular)
        }
    }
}

#Preview {
    MessageReactionAddView(position: .left, onTap: {})
    MessageReactionAddView(position: .right, onTap: {})
}
