import Foundation
import SwiftUI

struct AnytypeNavigationSpacer: View {
    
    // Alternative minHeight
    var minHeight: CGFloat = 0
    
    @Environment(\.anytypeNavigationPanelSize) var navigationSize
    
    var body: some View {
        Color.clear.frame(height: max(navigationSize.height, minHeight))
    }
}
