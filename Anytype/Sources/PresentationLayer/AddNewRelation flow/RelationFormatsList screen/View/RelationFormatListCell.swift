import SwiftUI
import AnytypeCore
import Services

struct RelationFormatListCell: View {
    
    let model: Model

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Image(asset: model.iconAsset)
                .foregroundColor(.Button.active)

            AnytypeText(model.title, style: .uxBodyRegular)
                .foregroundColor(.Text.primary)
                .lineLimit(1)
            
            Spacer()

            if model.isSelected {
                Image(asset: .X24.tick).foregroundColor(.Text.primary)
            }
        }
        .frame(height: 52)
        .divider(alignment: .leading)
    }
}

extension RelationFormatListCell {
    
    struct Model: Identifiable, Hashable {
        let id: String
        
        let title: String
        let iconAsset: ImageAsset
        let isSelected: Bool
    }
    
}
