import Foundation
import SwiftUI

struct SetsListWidgetSubmoduleView: View {
    
    let data: WidgetSubmoduleData
    
    var body: some View {
        SetsCommonListWidgetSubmoduleView(data: data, style: .list)
    }
}
