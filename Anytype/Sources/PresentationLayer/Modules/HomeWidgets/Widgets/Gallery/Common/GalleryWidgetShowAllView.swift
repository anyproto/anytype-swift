import Foundation
import SwiftUI

struct GalleryWidgetShowAllView: View {
    
    var onTap: () -> Void
    
    var body: some View {
        Text(Loc.Widgets.Actions.seeAllObjects)
            .anytypeStyle(.caption1Medium)
            .foregroundColor(.Control.secondary)
            .frame(width: 136)
            .frame(maxHeight: .infinity)
            .border(8, color: .Shape.transperentPrimary)
            .cornerRadius(8, style: .continuous)
            .shadow(color: .black.opacity(0.05), radius: 4)
            .fixTappableArea()
            .onTapGesture {
                onTap()
            }
    }
}
