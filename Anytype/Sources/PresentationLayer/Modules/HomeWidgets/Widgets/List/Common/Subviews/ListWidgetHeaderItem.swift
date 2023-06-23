import Foundation
import SwiftUI

struct ListWidgetHeaderItem: View {

    struct Model {
        let dataviewId: String
        let title: String
        let isSelected: Bool
        let onTap: () -> Void
    }
    
    let model: Model
    
    var body: some View {
        AnytypeText(model.title, style: .previewTitle2Medium, color: model.isSelected ? .Text.primary : .Widget.inactiveTab)
            .onTapGesture {
                model.onTap()
            }
    }
}
