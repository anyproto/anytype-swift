import Foundation
import SwiftUI

struct SetWidgetHeaderItem: View {

    struct Model {
        let dataviewId: String
        let title: String
        let onTap: () -> Void
        let isSelected: Bool
    }
    
    let model: Model
    
    var body: some View {
        Button(action: {
            model.onTap()
        }, label: {
            AnytypeText(model.title, style: .previewTitle2Medium, color: model.isSelected ? .Text.primary : .Button.active)
        })
    }
}
