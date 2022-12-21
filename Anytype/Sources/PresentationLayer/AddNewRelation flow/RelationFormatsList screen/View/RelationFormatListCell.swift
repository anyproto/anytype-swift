import SwiftUI
import AnytypeCore
import BlocksModels

struct RelationFormatListCell: View {
    
    let model: Model

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Image(asset: model.iconAsset).frame(width: 24, height: 24)

            AnytypeText(model.title, style: .uxBodyRegular, color: .TextNew.primary)
                .lineLimit(1)
            
            Spacer()

            if model.isSelected {
                Image(asset: .optionChecked).frame(width: 24, height: 24).foregroundColor(.TextNew.primary)
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
