import Foundation
import SwiftUI

struct ViewWidgetTabsView: View {
    
    let items: [ViewWidgetTabsItemModel]?
    
    var body: some View {
        Group {
            if let items = items, items.isNotEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(items, id: \.dataviewId) {
                            ViewWidgetTabsItemView(model: $0)
                        }
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 40)
                }
            }
        }
    }

}
