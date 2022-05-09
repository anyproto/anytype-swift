import SwiftUI

struct NewRelationFormatSectionView: View {
    
    let model: Model
    let onTap: () -> Void
    
    var body: some View {
        NewRelationSectionView(
            title: "Relation type".localized,
            contentViewBuilder: {
                contentView
            },
            onTap: onTap,
            isArrowVisible: true
        )
    }
    
    private var contentView: some View {
        HStack(spacing: 5) {
            Image(model.icon).frame(width: 24, height: 24)
            AnytypeText(model.title, style: .uxBodyRegular, color: .textPrimary)
                .lineLimit(1)
        }
    }
}

extension NewRelationFormatSectionView {
    
    struct Model: Hashable {
        let icon: String
        let title: String
    }
    
}

struct NewRelationFormatSectionView_Previews: PreviewProvider {
    static var previews: some View {
        NewRelationFormatSectionView(
            model: NewRelationFormatSectionView.Model(icon: "format/text", title: "Text"),
            onTap: {}
        )
    }
}
