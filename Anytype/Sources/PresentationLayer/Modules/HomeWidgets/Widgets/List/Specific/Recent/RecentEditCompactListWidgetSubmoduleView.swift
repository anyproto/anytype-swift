import Foundation
import SwiftUI

struct RecentEditCompactListWidgetSubmoduleView: View {
    
    let data: WidgetSubmoduleData
    
    var body: some View {
        RecentCommonListWidgetSubmoduleView(data: data, type: .recentEdit, style: .compactList)
    }
}
