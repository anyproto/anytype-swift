import SwiftUI
import Services

struct ObjectTypesUnifiedRowView: View {
    let showDivider: Bool

    @State private var model: ObjectTypesUnifiedRowViewModel

    init(info: ObjectTypeWidgetInfo, showDivider: Bool, output: (any CommonWidgetModuleOutput)?) {
        self.showDivider = showDivider
        self._model = State(wrappedValue: ObjectTypesUnifiedRowViewModel(info: info, output: output))
    }

    var body: some View {
        Button {
            model.onTapType()
        } label: {
            HStack(spacing: 12) {
                IconView(icon: model.typeIcon)
                    .frame(width: 20, height: 20)

                AnytypeText(model.typeName, style: .bodySemibold)
                    .foregroundStyle(Color.Text.primary)
                    .lineLimit(1)

                Spacer()

                if model.canCreateObject {
                    AsyncButton {
                        try await model.onCreateObject()
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
        .task(priority: .low) {
            await model.startSubscriptions()
        }
    }
}
