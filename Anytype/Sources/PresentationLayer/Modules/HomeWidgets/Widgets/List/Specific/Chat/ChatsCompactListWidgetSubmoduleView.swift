import Foundation
import SwiftUI

struct ChatsCompactListWidgetSubmoduleView: View {
    
    let data: WidgetSubmoduleData
    
    var body: some View {
        ChatsCommonListWidgetSubmoduleView(data: data, style: .compactList)
    }
}
