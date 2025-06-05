import SwiftUI

struct NewPropertyFormatSectionView: View {
    
    let model: Model
    
    var body: some View {
        HStack(spacing: 5) {
            Image(asset: model.icon)
                .foregroundColor(.Control.active)
            AnytypeText(model.title, style: .uxBodyRegular)
                .foregroundColor(.Text.primary)
                .lineLimit(1)
        }
    }
    
}

extension NewPropertyFormatSectionView {
    
    struct Model: Hashable {
        let icon: ImageAsset
        let title: String
    }
    
}

struct NewPropertyFormatSectionView_Previews: PreviewProvider {
    static var previews: some View {
        NewPropertyFormatSectionView(
            model: NewPropertyFormatSectionView.Model(icon: .X24.text, title: "Text")
        )
    }
}
