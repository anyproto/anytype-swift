import Foundation
import SwiftUI

struct CollectionsListWidgetSubmoduleView: View {
    
    let data: WidgetSubmoduleData
    
    var body: some View {
        CollectionsCommonListWidgetSubmoduleView(data: data, style: .list)
    }
}
