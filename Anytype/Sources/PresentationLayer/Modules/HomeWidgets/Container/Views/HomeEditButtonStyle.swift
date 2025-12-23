import Foundation
import SwiftUI

struct HomeEditButton: View {
    
    let text: String
    let homeState: HomeWidgetsState
    let action: () -> Void
    
    var body: some View {
        Button(
            action: action,
            label: {
                AnytypeText(text, style: .uxTitle2Medium)
                    .foregroundStyle(Color.Text.primary)
                    .padding(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
                    .lineLimit(1)
            }
        )
        .frame(maxWidth: .infinity)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .setZeroOpacity(!homeState.isReadWrite)
        .animation(.default, value: homeState)
    }
}
