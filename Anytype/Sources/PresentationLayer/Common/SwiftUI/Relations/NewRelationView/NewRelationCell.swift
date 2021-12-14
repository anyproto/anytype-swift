import SwiftUI
import AnytypeCore
import BlocksModels


struct NewRelationCell: View {
    let realtionMetadata: RelationMetadata

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Image(realtionMetadata.format.iconName)
                .frame(width: 24, height: 24)
            Spacer.fixedWidth(12)
            AnytypeText(realtionMetadata.name, style: .uxBodyRegular, color: .textPrimary)
                .lineLimit(1)
            Spacer()
        }
        .frame(height: 52)
        .background(Color.background)
    }
}
