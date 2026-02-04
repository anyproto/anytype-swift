import SwiftUI
import AnytypeCore
import Services

struct PropertyFormatListCell: View {
    
    let model: Model

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Image(asset: model.iconAsset)
                .foregroundStyle(Color.Control.secondary)

            AnytypeText(model.title, style: .uxBodyRegular)
                .foregroundStyle(Color.Text.primary)
                .lineLimit(1)

            Spacer()

            if model.isSelected {
                Image(asset: .X24.tick).foregroundStyle(Color.Text.primary)
            }
        }
        .frame(height: 52)
        .divider(alignment: .leading)
    }
}

extension PropertyFormatListCell {
    
    struct Model: Identifiable, Hashable {
        let id: String
        
        let title: String
        let iconAsset: ImageAsset
        let isSelected: Bool
    }
    
}
