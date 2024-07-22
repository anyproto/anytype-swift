import Foundation
import SwiftUI

struct SetObjectCompactListLegacyWidgetSubmoduleView: View {
    
    let data: WidgetSubmoduleData
    
    var body: some View {
        SetObjectCommonListWidgetSubmoduleView(data: data, style: .compactList)
    }
}
