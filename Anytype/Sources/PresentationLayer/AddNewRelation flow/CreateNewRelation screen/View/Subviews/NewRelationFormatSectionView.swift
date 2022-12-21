import SwiftUI

struct NewRelationFormatSectionView: View {
    
    let model: Model
    
    var body: some View {
        HStack(spacing: 5) {
            Image(asset: model.icon).frame(width: 24, height: 24)
            AnytypeText(model.title, style: .uxBodyRegular, color: .TextNew.primary)
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
            model: NewRelationFormatSectionView.Model(icon: .Format.text, title: "Text")
        )
    }
}
