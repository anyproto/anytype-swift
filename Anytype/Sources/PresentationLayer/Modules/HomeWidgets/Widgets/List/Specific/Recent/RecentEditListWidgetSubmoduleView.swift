import Foundation
import SwiftUI

struct RecentEditListWidgetSubmoduleView: View {
    
    let data: WidgetSubmoduleData
    
    var body: some View {
        RecentCommonListWidgetSubmoduleView(data: data, type: .recentEdit, style: .list)
    }
}
