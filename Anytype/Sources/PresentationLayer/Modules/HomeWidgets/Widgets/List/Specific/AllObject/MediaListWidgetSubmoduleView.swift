import Foundation
import SwiftUI

struct MediaListWidgetSubmoduleView: View {
    
    let data: WidgetSubmoduleData
    
    var body: some View {
        AllObjectCommonListWidgetSubmoduleView(data: data, style: .list, type: .media)
    }
}
