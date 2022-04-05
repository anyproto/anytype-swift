import SwiftUI

struct NewRelationFormatSectionView: View {
    
    let format: SupportedRelationFormat
    let onTap: () -> Void
    
    var body: some View {
        NewRelationSectionView(
            title: "Connect with".localized,
            contentViewBuilder: {
                contentView
            },
            onTap: onTap,
            isArrowVisible: true
        )
    }
    
    private var contentView: some View {
        HStack(spacing: 5) {
            Image(format.icon).frame(width: 24, height: 24)
            AnytypeText(format.title, style: .uxBodyRegular, color: .textPrimary)
                .lineLimit(1)
        }
    }
}

struct NewRelationFormatSectionView_Previews: PreviewProvider {
    static var previews: some View {
        NewRelationFormatSectionView(format: .text, onTap: {})
    }
}
