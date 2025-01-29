import Foundation
import SwiftUI

struct MessageReactionAddView: View {
    
    let isYourMessage: Bool
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
    MessageReactionAddView(isYourMessage: false, onTap: {})
    MessageReactionAddView(isYourMessage: true, onTap: {})
}
