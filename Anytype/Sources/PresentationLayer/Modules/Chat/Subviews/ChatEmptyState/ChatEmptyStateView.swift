import Foundation
import SwiftUI

struct ChatEmptyStateView: View {
        
    let title: String
    let description: String
    let action: (() -> Void)?
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Spacer()
            Text(title)
                .anytypeStyle(.bodyRegular)
                .foregroundStyle(Color.Text.primary)
            Text(description)
                .anytypeStyle(.bodyRegular)
                .foregroundStyle(Color.Control.transparentActive)
            if let action {
                Spacer.fixedHeight(10)
                StandardButton(
                    Loc.Chat.Empty.Button.title,
                    style: .secondarySmall,
                    action: action
                )
            }
            Spacer()
        }
    }
}
