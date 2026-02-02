import SwiftUI

struct ObjectTypesUnifiedWidgetView: View {
    let typeInfos: [ObjectTypeWidgetInfo]
    let canCreateType: Bool
    let onCreateType: () -> Void
    let output: (any CommonWidgetModuleOutput)?

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(typeInfos.enumerated()), id: \.element.id) { index, info in
                ObjectTypesUnifiedRowView(
                    info: info,
                    showDivider: index < typeInfos.count - 1 || canCreateType,
                    output: output
                )
            }

            if canCreateType {
                newTypeRow
            }
        }
        .background(Color.Background.widget)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var newTypeRow: some View {
        Button {
            onCreateType()
        } label: {
            HStack(spacing: 12) {
                Image(asset: .X18.plus)
                    .foregroundStyle(Color.Text.secondary)
                    .frame(width: 18, height: 18)

                AnytypeText(Loc.newType, style: .bodySemibold)
                    .foregroundStyle(Color.Text.secondary)
                    .lineLimit(1)

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .fixTappableArea()
        }
        .buttonStyle(.plain)
    }
}
