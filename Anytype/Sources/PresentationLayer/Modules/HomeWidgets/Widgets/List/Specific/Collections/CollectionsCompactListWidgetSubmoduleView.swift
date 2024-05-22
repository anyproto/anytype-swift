import Foundation
import SwiftUI

struct CollectionsCompactListWidgetSubmoduleView: View {
    
    let data: WidgetSubmoduleData
    
    var body: some View {
        CollectionsCommonListWidgetSubmoduleView(data: data, style: .compactList)
    }
}
