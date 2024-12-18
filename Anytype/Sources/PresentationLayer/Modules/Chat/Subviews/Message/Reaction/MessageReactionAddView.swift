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
                .foregroundStyle(isYourMessage ? Color.Control.white : Color.Control.button)
                .frame(width: 32, height: 32)
                .background(Color.Shape.transperentPrimary)
                .cornerRadius(16, style: .circular)
        }
    }
}

#Preview {
    MessageReactionAddView(isYourMessage: false, onTap: {})
    MessageReactionAddView(isYourMessage: true, onTap: {})
}
