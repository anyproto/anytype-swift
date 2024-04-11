import Foundation
import SwiftUI

struct WidgetEmptyView: View {
    
    let title: String
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Spacer()
            AnytypeText(title, style: .relation2Regular)
                .foregroundColor(.Text.secondary)
            Spacer()
        }
    }
}
