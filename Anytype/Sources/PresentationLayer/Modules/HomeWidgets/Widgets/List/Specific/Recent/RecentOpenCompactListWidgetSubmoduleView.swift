import Foundation
import SwiftUI

struct RecentOpenCompactListWidgetSubmoduleView: View {
    
    let data: WidgetSubmoduleData
    
    var body: some View {
        RecentCommonListWidgetSubmoduleView(data: data, type: .recentOpen, style: .compactList)
    }
}
