import Foundation
import SwiftUI

struct PagesCompactListWidgetSubmoduleView: View {
    
    let data: WidgetSubmoduleData
    
    var body: some View {
        AllObjectCommonListWidgetSubmoduleView(data: data, style: .compactList, type: .pages)
    }
}
