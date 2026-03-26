import SwiftUI
import Services
import DesignKit

struct MemberRow<Trailing: View>: View {

    let icon: ObjectIcon?
    let name: String
    let globalName: String
    @ViewBuilder let trailing: () -> Trailing

    var body: some View {
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

            trailing()
        }
        .fixTappableArea()
        .padding(.horizontal, 16)
        .padding(.vertical, 9)
        .frame(height: 72)
        .newDivider()
    }
}
