import Foundation
import SwiftUI

struct ListsListWidgetSubmoduleView: View {
    
    let data: WidgetSubmoduleData
    
    var body: some View {
        AllObjectCommonListWidgetSubmoduleView(data: data, style: .list, type: .lists)
    }
}
