import Foundation
import SwiftUI

struct BinWidgetView: View {
    
    let data: WidgetSubmoduleData
    
    var body: some View {
        BinWidgetSubmoduleInternalView(data: data)
            .id(data.widgetBlockId)
    }
}

private struct BinWidgetSubmoduleInternalView: View {
    
    let data: WidgetSubmoduleData
    
    init(data: WidgetSubmoduleData) {
        self.data = data
    }
    
    var body: some View {
        Color.red.frame(height: 50)
    }
}
