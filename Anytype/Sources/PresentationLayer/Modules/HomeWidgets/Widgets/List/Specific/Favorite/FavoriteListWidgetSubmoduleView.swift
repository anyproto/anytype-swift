import Foundation
import SwiftUI

struct FavoriteListWidgetSubmoduleView: View {
    
    let data: WidgetSubmoduleData
    
    var body: some View {
        FavoriteCommonListWidgetSubmoduleView(data: data, style: .list)
    }
}
