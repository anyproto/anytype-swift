import Foundation
import SwiftUI

struct WidgetEmptyView: View {
    
    let onCreateTap: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 10) {
            Text(Loc.Widgets.Empty.title)
                .anytypeStyle(.relation2Regular)
                .foregroundColor(.Text.secondary)
            if let onCreateTap {
                StandardButton(
                    .text(Loc.Widgets.Empty.createObject),
                    style: .secondaryXSmall,
                    action: onCreateTap
                )
            }
        }
        .padding(EdgeInsets(top: 12, leading: 16, bottom: 14, trailing: 16))
    }
}
