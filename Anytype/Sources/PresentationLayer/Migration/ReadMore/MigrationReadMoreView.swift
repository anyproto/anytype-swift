import SwiftUI

struct MigrationReadMoreView: View {
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            DragIndicator()
            Spacer.fixedHeight(44)
            Image(asset: .Migration.loading)
                .frame(width: 48, height: 48)
            Spacer.fixedHeight(12)
            AnytypeText(Loc.Migration.ReadMore.option1, style: .subheading)
                .foregroundColor(.Text.primary)
            Spacer.fixedHeight(4)
            AnytypeText(Loc.Migration.ReadMore.description1, style: .calloutRegular)
                .foregroundColor(.Text.secondary)
            
            Spacer.fixedHeight(32)
            Image(asset: .Migration.data)
                .frame(width: 48, height: 48)
            Spacer.fixedHeight(12)
            AnytypeText(Loc.Migration.ReadMore.option2, style: .subheading)
                .foregroundColor(.Text.primary)
            Spacer.fixedHeight(4)
            AnytypeText(Loc.Migration.ReadMore.description2, style: .calloutRegular)
                .foregroundColor(.Text.secondary)
            Spacer.fixedHeight(8)
            AnytypeText(Loc.Migration.ReadMore.description3, style: .calloutRegular)
                .foregroundColor(.Text.secondary)
            Spacer()
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
