import SwiftUI
import AnytypeCore
import BlocksModels


struct CreateNewRelationCell: View {
    let format: RelationMetadata.Format
    let isSelected: Bool

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(format.iconName)
                .frame(width: 24, height: 24)

            AnytypeText(format.name, style: .uxBodyRegular, color: .textPrimary)
                .lineLimit(1)

            Spacer()

            if isSelected {
                Image.optionChecked.frame(width: 24, height: 24).foregroundColor(.buttonSelected)
            }
        }
        .frame(height: 52)
    }
}
