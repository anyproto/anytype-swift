import SwiftUI
import Services
import DesignKit

struct MemberSelectionRow: View {

    let icon: ObjectIcon?
    let name: String
    let globalName: String
    @Binding var isSelected: Bool

    var body: some View {
        Button {
            isSelected.toggle()
        } label: {
            HStack(spacing: 12) {
                IconView(icon: icon?.icon)
                    .frame(width: 48, height: 48)

                VStack(alignment: .leading, spacing: 0) {
                    AnytypeText(name, style: .uxTitle2Medium)
                        .foregroundStyle(Color.Text.primary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                    AnytypeText(globalName, style: .caption1Regular)
                        .foregroundStyle(Color.Text.secondary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                AnytypeCircleCheckbox(checked: $isSelected)
                    .allowsHitTesting(false)
            }
            .fixTappableArea()
            .padding(.vertical, 9)
            .frame(height: 72)
            .newDivider()
        }
        .buttonStyle(.plain)
    }
}
