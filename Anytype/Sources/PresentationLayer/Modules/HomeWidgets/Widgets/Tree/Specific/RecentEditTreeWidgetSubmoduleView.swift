import Foundation
import SwiftUI

struct RecentEditTreeWidgetSubmoduleView: View {
    
    let data: WidgetSubmoduleData
    
    var body: some View {
        RecentTreeWidgetSubmoduleView(data: data, type: .recentEdit)
    }
}
