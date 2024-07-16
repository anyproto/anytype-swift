import Foundation
import SwiftUI

struct SetObjectListLegacyWidgetSubmoduleView: View {
    
    let data: WidgetSubmoduleData
    
    var body: some View {
        SetObjectCommonListWidgetSubmoduleView(data: data, style: .list)
    }
}
