import Foundation
import SwiftUI

struct FilesListWidgetSubmoduleView: View {
    
    let data: WidgetSubmoduleData
    
    var body: some View {
        AllObjectCommonListWidgetSubmoduleView(data: data, style: .list, type: .files)
    }
}
