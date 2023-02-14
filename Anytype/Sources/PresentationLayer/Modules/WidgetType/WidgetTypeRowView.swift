import Foundation
import SwiftUI

struct WidgetTypeRowView: View {

    struct Model: Hashable {
        let title: String
        let description: String
        let image: ImageAsset
        @EquatableNoop var onTap: () -> Void
    }
    
    let model: Model
    
    var body: some View {
        Button {
            model.onTap()
        } label: {
            content
        }
    }
    
    private var content: some View {
        HStack(spacing: 0) {
            Spacer.fixedWidth(18)
            Image(asset: model.image)
            Spacer.fixedWidth(16)
            VStack(alignment: .leading) {
                Spacer()
                HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 0) {
                        AnytypeText(model.title, style: .uxTitle2Medium, color: .Text.primary)
                            .lineLimit(1)
                        AnytypeText(model.description, style: .caption1Regular, color: .Text.secondary)
                            .lineLimit(1)
                    }
                    Spacer()
                }
                Spacer()
            }
            .newDivider()
            Spacer.fixedWidth(18)
        }
        .frame(height: 60)
    }
}

struct WidgetTypeRowView_Previews: PreviewProvider {
    static var previews: some View {
        WidgetTypeRowView(
            model: WidgetTypeRowView.Model(title: "List", description: "Widget with list view of set object", image: .addNew, onTap: {})
        )
    }
}
