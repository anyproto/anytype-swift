import Foundation
import SwiftUI

struct MediaCompactListWidgetSubmoduleView: View {
    
    let data: WidgetSubmoduleData
    
    var body: some View {
        AllObjectCommonListWidgetSubmoduleView(data: data, style: .compactList, type: .media)
    }
}
