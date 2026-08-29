import SwiftUI
import Services

struct UnifiedSearchPickerRow: Identifiable, Hashable {
    let id: String
    let title: String
    let icon: Icon
    var subtitle: String? = nil
}

// The full browse behind a picker chip (People, Types) - pick one row to add
// its filter token. Rows come pre-sorted by the caller.
struct UnifiedSearchPickerView: View {

    let rows: [UnifiedSearchPickerRow]
    let onSelect: (UnifiedSearchPickerRow) -> Void

    @State private var searchText = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            SearchBar(text: $searchText, focused: false, shouldShowDivider: false)
            list
                .fitIPadToReadableContentGuide()
        }
        .background(Color.Background.secondary)
    }

    private var filteredRows: [UnifiedSearchPickerRow] {
        guard searchText.isNotEmpty else { return rows }
        return rows.filter { $0.title.localizedStandardContains(searchText) }
    }

    @ViewBuilder
    private var list: some View {
        if filteredRows.isEmpty {
            EmptyStateView(
                title: Loc.nothingFound,
                subtitle: "",
                style: .plain
            )
        } else {
            PlainList {
                ForEach(filteredRows) { row in
                    Button {
                        dismiss()
                        onSelect(row)
                    } label: {
                        HStack(spacing: 12) {
                            IconView(icon: row.icon)
                                .frame(width: 40, height: 40)
                            VStack(alignment: .leading, spacing: 0) {
                                AnytypeText(row.title, style: .previewTitle2Medium)
                                    .foregroundStyle(Color.Text.primary)
                                    .lineLimit(1)
                                if let subtitle = row.subtitle {
                                    AnytypeText(subtitle, style: .relation2Regular)
                                        .foregroundStyle(Color.Text.secondary)
                                        .lineLimit(1)
                                }
                            }
                            Spacer()
                        }
                        .frame(minHeight: 56)
                        .newDivider()
                        .padding(.horizontal, 16)
                        .fixTappableArea()
                    }
                    .buttonStyle(.plain)
                }
            }
            .scrollIndicators(.never)
        }
    }
}
