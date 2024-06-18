import Foundation
import SwiftUI

struct FavoriteCompactListWidgetSubmoduleView: View {
    
    let data: WidgetSubmoduleData
    
    var body: some View {
        FavoriteCommonListWidgetSubmoduleView(data: data, style: .compactList)
    }
}
