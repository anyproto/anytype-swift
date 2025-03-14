import Foundation
import SwiftUI

struct ShareArrowRow: View {
    
    let title: String
    let description: String?
    
    var body: some View {
        HStack(spacing: 0) {
            AnytypeText(title, style: .uxBodyRegular)
                .foregroundColor(.Text.primary)
            Spacer()
            if let description {
                AnytypeText(description, style: .uxBodyRegular)
                    .foregroundColor(.Text.secondary)
                    .lineLimit(1)
                Spacer.fixedWidth(10)
            }
            Image(asset: .RightAttribute.disclosure).foregroundColor(.Text.tertiary)
        }
    }
}
