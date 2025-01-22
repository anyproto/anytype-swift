import Foundation
import SwiftUI

struct BookmarksListWidgetSubmoduleView: View {
    
    let data: WidgetSubmoduleData
    
    var body: some View {
        AllObjectCommonListWidgetSubmoduleView(data: data, style: .list, type: .bookmarks)
    }
}
