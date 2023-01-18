import Foundation
import SwiftUI

struct HomeEditButton: View {
    
    let text: String
    let action: () -> Void
    
    var body: some View {
        Button(
            action: action,
            label: {
                AnytypeText(text, style: .uxTitle2Medium, color: .Text.primary)
                    .padding(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
            }
        )
        .backgroundMaterial(.thinMaterial)
        .cornerRadius(8, style: .continuous)
    }
}
