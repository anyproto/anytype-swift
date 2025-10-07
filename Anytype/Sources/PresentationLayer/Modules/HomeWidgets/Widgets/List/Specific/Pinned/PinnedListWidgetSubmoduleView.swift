import Foundation
import SwiftUI

struct PinnedListWidgetSubmoduleView: View {
    
    let data: WidgetSubmoduleData
    
    var body: some View {
        PinnedCommonListWidgetSubmoduleView(data: data, style: .list)
    }
}
