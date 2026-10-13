import SwiftUI

/// The one compact activity row: avatars, a single truncated line, and a trailing state.
/// Typing, text-only agent status and run summaries all use it.
struct ChatActivityRowView: View {

    private enum Constants {
        static let height: CGFloat = 24
        static let iconSize: CGFloat = 20
        static let maxIcons = 3
    }

    let data: ChatActivityRowData

    var body: some View {
        HStack(spacing: 6) {
            icons
            AnytypeText(data.text, style: .caption1Regular)
                .foregroundStyle(Color.Text.secondary)
                .lineLimit(1)
                .truncationMode(.tail)
            trailing
                .fixedSize()
            Spacer(minLength: 0)
        }
        .frame(height: Constants.height)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(data.accessibilityLabel)
    }

    private var icons: some View {
        HStack(spacing: -4) {
            ForEach(Array(data.icons.prefix(Constants.maxIcons).enumerated()), id: \.offset) { _, icon in
                IconView(icon: icon)
                    .frame(width: Constants.iconSize, height: Constants.iconSize)
            }
        }
    }

    @ViewBuilder
    private var trailing: some View {
        switch data.trailing {
        case .dots:
            TypingDotsView()
        case .completed:
            Image(asset: .X18.tick)
                .foregroundStyle(Color.Control.secondary)
        case .failed:
            Image(asset: .X18.redAttention)
        case .none:
            EmptyView()
        }
    }
}

/// A run's compact line; tapping it opens the run's calls.
struct ChatActivityRunRowView: View {

    let controller: ChatActivityController
    let runId: String

    var body: some View {
        if let row = controller.runRow(runId: runId) {
            Button {
                controller.onTapRun(id: runId)
            } label: {
                ChatActivityRowView(data: row)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityHint(Loc.Chat.Activity.showDetails)
        }
    }
}

/// Typing and text-only status rows near the composer.
struct ChatActivityComposerRowsView: View {

    let controller: ChatActivityController

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        let rows = controller.composerRows
        VStack(alignment: .leading, spacing: 0) {
            ForEach(rows) { row in
                ChatActivityRowView(data: row)
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, rows.isEmpty ? 0 : 4)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: rows.map(\.id))
    }
}
