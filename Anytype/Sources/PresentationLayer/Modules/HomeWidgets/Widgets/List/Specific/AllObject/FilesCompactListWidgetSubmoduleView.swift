import Foundation
import SwiftUI

struct FilesCompactListWidgetSubmoduleView: View {
    
    let data: WidgetSubmoduleData
    
    var body: some View {
        AllObjectCommonListWidgetSubmoduleView(data: data, style: .compactList, type: .files)
    }
}
