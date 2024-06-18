import Foundation
import SwiftUI

struct SetObjectCompactListWidgetSubmoduleView: View {
    
    let data: WidgetSubmoduleData
    
    var body: some View {
        SetObjectCommonListWidgetSubmoduleView(data: data, style: .compactList)
    }
}
