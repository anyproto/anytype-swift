import Foundation
import SwiftUI

struct SetsCompactListWidgetSubmoduleView: View {
    
    let data: WidgetSubmoduleData
    
    var body: some View {
        SetsCommonListWidgetSubmoduleView(data: data, style: .compactList)
    }
}
