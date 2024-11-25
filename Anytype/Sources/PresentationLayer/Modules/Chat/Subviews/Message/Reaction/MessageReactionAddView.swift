import Foundation
import SwiftUI

struct MessageReactionAddView: View {
    
    let onTap: () -> Void
    
    var body: some View {
        Button {
            onTap()
        } label: {
            Image(asset: .X24.reaction)
                .frame(width: 32, height: 32)
                .background(Color.Background.highlightedMedium)
                .cornerRadius(16, style: .circular)
        }
    }
}

#Preview {
    MessageReactionAddView(onTap: {})
}
