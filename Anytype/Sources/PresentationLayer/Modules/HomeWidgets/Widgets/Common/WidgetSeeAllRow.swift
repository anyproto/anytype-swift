import SwiftUI
import DesignKit

struct WidgetSeeAllRow: View {
    
    let onTap: () -> Void
    
    var body: some View {
        Button {
            onTap()
        } label: {
            AnytypeText("See all", style: .caption1Medium)
                .foregroundColor(Color.Text.secondary)
                .frame(height: 40)
        }
    }
}
