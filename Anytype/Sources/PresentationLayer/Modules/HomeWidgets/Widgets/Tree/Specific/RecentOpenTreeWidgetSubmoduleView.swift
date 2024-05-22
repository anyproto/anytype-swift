import Foundation
import SwiftUI

struct RecentOpenTreeWidgetSubmoduleView: View {
    
    let data: WidgetSubmoduleData
    
    var body: some View {
        RecentTreeWidgetSubmoduleView(data: data, type: .recentOpen)
    }
}
