import SwiftUI

struct NewRelationFormatSectionView: View {
    
    let model: Model
    
    var body: some View {
        HStack(spacing: 5) {
            Image(asset: model.icon)
                .foregroundColor(.Button.active)
            AnytypeText(model.title, style: .uxBodyRegular, color: .Text.primary)
                .lineLimit(1)
        }
    }
    
}

extension NewRelationFormatSectionView {
    
    struct Model: Hashable {
        let icon: ImageAsset
        let title: String
    }
    
}

struct NewRelationFormatSectionView_Previews: PreviewProvider {
    static var previews: some View {
        NewRelationFormatSectionView(
            model: NewRelationFormatSectionView.Model(icon: .X24.text, title: "Text")
        )
    }
}
