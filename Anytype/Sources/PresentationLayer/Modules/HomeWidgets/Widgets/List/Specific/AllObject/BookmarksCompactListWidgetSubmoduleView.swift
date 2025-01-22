import Foundation
import SwiftUI

struct BookmarksCompactListWidgetSubmoduleView: View {
    
    let data: WidgetSubmoduleData
    
    var body: some View {
        AllObjectCommonListWidgetSubmoduleView(data: data, style: .compactList, type: .bookmarks)
    }
}
