import SwiftUI
import DesignKit

struct WidgetSeeAllRow: View {
    
    let onTap: () -> Void
    
    var body: some View {
        Button {
            onTap()
        } label: {
            AnytypeText(Loc.seeAll, style: .caption1Medium)
                .foregroundStyle(Color.Text.secondary)
                .frame(height: 40)
        }
    }
}
