import Foundation
import SwiftUI

struct WidgetEmptyView: View {
    
    var body: some View {
        VStack(spacing: 10) {
            Text(Loc.Widgets.Empty.title)
                .anytypeStyle(.relation2Regular)
                .foregroundColor(.Text.secondary)
        }
        .padding(EdgeInsets(top: 12, leading: 16, bottom: 14, trailing: 16))
    }
}
