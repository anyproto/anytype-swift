import Foundation
import SwiftUI

struct ChatEmptyStateView: View {
        
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Spacer()
            Text(Loc.Chat.Empty.title)
                .anytypeStyle(.bodyRegular)
                .foregroundStyle(Color.Text.primary)
            Text(Loc.Chat.Empty.description)
                .anytypeStyle(.bodyRegular)
                .foregroundStyle(Color.Text.secondary)
            Spacer()
        }
    }
}
