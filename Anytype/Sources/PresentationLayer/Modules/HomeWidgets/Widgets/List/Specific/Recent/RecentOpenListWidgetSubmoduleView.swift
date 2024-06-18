import Foundation
import SwiftUI

struct RecentOpenListWidgetSubmoduleView: View {
    
    let data: WidgetSubmoduleData
    
    var body: some View {
        RecentCommonListWidgetSubmoduleView(data: data, type: .recentOpen, style: .list)
    }
}
