import SwiftUI
import DesignKit

struct ManageSectionRowView: View {
    let row: ManageSectionsViewModel.Row
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            if row.isLocked {
                Color.clear.frame(width: 24, height: 24)
            } else {
                AnytypeCircleCheckbox(checked: row.visible)
            }
            AnytypeText(row.title, style: .uxBodyRegular)
                .lineLimit(1)
                .truncationMode(.tail)
                .foregroundStyle(Color.Text.primary)
            Spacer(minLength: 0)
        }
        .frame(height: 52)
        .padding(.horizontal, 16)
        .contentShape(Rectangle())
        .onTapGesture {
            guard !row.isLocked else { return }
            onToggle()
        }
        .newDivider(leadingPadding: 16, trailingPadding: 16)
    }
}
