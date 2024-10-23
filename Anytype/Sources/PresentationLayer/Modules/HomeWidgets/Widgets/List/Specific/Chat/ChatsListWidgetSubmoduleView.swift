import Foundation
import SwiftUI

struct ChatsListWidgetSubmoduleView: View {
    
    let data: WidgetSubmoduleData
    
    var body: some View {
        ChatsCommonListWidgetSubmoduleView(data: data, style: .list)
    }
}
