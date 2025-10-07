import Foundation
import SwiftUI

struct PinnedCompactListWidgetSubmoduleView: View {
    
    let data: WidgetSubmoduleData
    
    var body: some View {
        PinnedCommonListWidgetSubmoduleView(data: data, style: .compactList)
    }
}
