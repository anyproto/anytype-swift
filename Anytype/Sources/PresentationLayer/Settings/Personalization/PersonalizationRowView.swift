import Foundation
import SwiftUI

struct PersonalizationRowView: View {
    
    let title: String
    let descriontion: String?
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 0) {
                AnytypeText(title, style: .uxBodyRegular, color: .Text.primary)
                Spacer()
                if let descriontion {
                    AnytypeText(descriontion, style: .uxBodyRegular, color: .Text.secondary)
                    Spacer.fixedWidth(10)
                }
                Image(asset: .arrowForward).foregroundColor(.Text.tertiary)
            }
            .padding(.vertical, 14)
            .divider()
            .padding(.horizontal, 20)
        }
    }
}
