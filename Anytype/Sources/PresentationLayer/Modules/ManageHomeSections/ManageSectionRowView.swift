import SwiftUI
import DesignKit

struct ManageSectionRowView: View {
    let title: String
    let isLocked: Bool
    let visible: Bool
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            if isLocked {
                Color.clear.frame(width: 24, height: 24)
            } else {
                AnytypeCircleCheckbox(checked: visible)
            }
            AnytypeText(title, style: .uxBodyRegular)
                .lineLimit(1)
                .truncationMode(.tail)
                .foregroundStyle(Color.Text.primary)
            Spacer(minLength: 0)
        }
        .frame(height: 52)
        .padding(.horizontal, 16)
        .contentShape(Rectangle())
        .onTapGesture {
            guard !isLocked else { return }
            onToggle()
        }
        .newDivider(leadingPadding: 16, trailingPadding: 16)
    }
}
