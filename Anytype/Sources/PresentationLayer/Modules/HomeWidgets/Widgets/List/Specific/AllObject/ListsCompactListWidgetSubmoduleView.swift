import Foundation
import SwiftUI

struct ListsCompactListWidgetSubmoduleView: View {
    
    let data: WidgetSubmoduleData
    
    var body: some View {
        AllObjectCommonListWidgetSubmoduleView(data: data, style: .compactList, type: .lists)
    }
}
