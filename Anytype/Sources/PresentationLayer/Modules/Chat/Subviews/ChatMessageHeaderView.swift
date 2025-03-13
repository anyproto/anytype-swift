import SwiftUI

struct ChatMessageHeaderView: View {
    let text: String
    
    var body: some View {
        HStack {
            Spacer()
            Text(text)
                .anytypeStyle(.caption1Medium)
                .foregroundColor(.Control.transparentActive)
                .frame(height: 50)
            Spacer()
        }
    }
}
