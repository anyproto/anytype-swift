import Foundation
import SwiftUI

struct PagesListWidgetSubmoduleView: View {
    
    let data: WidgetSubmoduleData
    
    var body: some View {
        AllObjectCommonListWidgetSubmoduleView(data: data, style: .list, type: .pages)
    }
}
