import Foundation
import SwiftUI

struct SetObjectListWidgetSubmoduleView: View {
    
    let data: WidgetSubmoduleData
    
    var body: some View {
        SetObjectCommonListWidgetSubmoduleView(data: data, style: .list)
    }
}
