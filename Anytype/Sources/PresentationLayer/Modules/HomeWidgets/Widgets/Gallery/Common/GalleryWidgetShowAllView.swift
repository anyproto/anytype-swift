import Foundation
import SwiftUI

struct GalleryWidgetShowAllView: View {
    
    var onTap: () -> Void
    
    var body: some View {
        Button {
            onTap()
        } label: {
            Text(Loc.Widgets.Actions.seeAllObjects)
                .anytypeStyle(.caption1Medium)
                .foregroundStyle(Color.Control.secondary)
                .frame(width: 136)
                .frame(maxHeight: .infinity)
                .border(8, color: .Shape.transparentPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .shadow(color: .black.opacity(0.05), radius: 4)
                .fixTappableArea()
        }
        .buttonStyle(.plain)
    }
}
