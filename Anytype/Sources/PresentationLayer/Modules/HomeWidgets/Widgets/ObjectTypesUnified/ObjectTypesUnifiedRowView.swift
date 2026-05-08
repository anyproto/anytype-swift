import SwiftUI
import Services

struct ObjectTypesUnifiedRowView: View {
    let info: ObjectTypeWidgetInfo
    let showDivider: Bool
    let onTap: (ObjectTypeWidgetInfo) -> Void
    let onCreate: (ObjectTypeWidgetInfo) async throws -> Void

    var body: some View {
        Button {
            onTap(info)
        } label: {
            HStack(spacing: 12) {
                IconView(icon: info.icon)
                    .frame(width: 20, height: 20)

                AnytypeText(info.name, style: .bodySemibold)
                    .foregroundStyle(Color.Text.primary)
                    .lineLimit(1)

                Spacer()

                if info.canCreateObject {
                    AsyncButton {
                        try await onCreate(info)
                    } label: {
                        Image(asset: .X18.plus)
                            .foregroundStyle(Color.Text.secondary)
                    }
                }
            }
            .fixTappableArea()
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .if(showDivider) {
            $0.newDivider(leadingPadding: 16, trailingPadding: 16, color: .Widget.divider)
        }
    }
}
