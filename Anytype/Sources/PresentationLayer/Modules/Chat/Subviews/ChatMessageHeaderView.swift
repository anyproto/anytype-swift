import SwiftUI

struct ChatMessageHeaderView: View {
    let text: String
    
    var body: some View {
        Text(text)
            .anytypeStyle(.caption1Medium)
            .foregroundColor(.Control.transparentActive)
            .frame(height: 50)
    }
}
