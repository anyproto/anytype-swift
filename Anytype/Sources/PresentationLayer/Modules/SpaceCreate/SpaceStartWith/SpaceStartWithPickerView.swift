import SwiftUI
import AnytypeCore

struct SpaceStartWithPickerView: View {

    let data: SpaceStartWithData
    let onSelectOption: (SpaceStartWithOption) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            AnytypeText("Initial screen", style: .uxTitle1Semibold)
            SpaceTypePickerRow(
                icon: .X32.file,
                title: Loc.SpaceCreate.StartWith.page,
                subtitle: "",
                onTap: {
                    dismiss()
                    onSelectOption(.page)
                }
            )
            SpaceTypePickerRow(
                icon: .Channel.chat,
                title: Loc.SpaceCreate.StartWith.chat,
                subtitle: "",
                onTap: {
                    dismiss()
                    onSelectOption(.chat)
                }
            )
            SpaceTypePickerRow(
                icon: .X32.dashboard,
                title: "Widgets",
                subtitle: "",
                onTap: {
                    dismiss()
                    onSelectOption(.widgets)
                }
            )
            Spacer()
        }
        .fitPresentationDetents()
    }
}
