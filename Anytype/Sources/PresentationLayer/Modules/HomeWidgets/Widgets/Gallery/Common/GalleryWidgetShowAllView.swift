import Foundation
import SwiftUI

struct GalleryWidgetShowAllView: View {
    
    var onTap: () -> Void
    
    var body: some View {
        Text(Loc.Widgets.Actions.seeAllObjects)
            .anytypeStyle(.caption1Medium)
            .foregroundColor(.Button.active)
            .frame(width: 136)
            .frame(maxHeight: .infinity)
            .background(Color.Background.primary)
            .border(8, color: .Shape.primary)
            .cornerRadius(8, style: .continuous)
            .shadow(color: .black.opacity(0.05), radius: 4)
            .fixTappableArea()
            .onTapGesture {
                onTap()
            }
    }
}
