import Foundation
import SwiftUI

struct AnytypeRow: View {
    
    let title: String
    let description: String?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
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
                Image(asset: .RightAttribute.disclosure)
            }
            .padding(.vertical, 14)
            .divider()
            .padding(.horizontal, 20)
        }
    }
}
