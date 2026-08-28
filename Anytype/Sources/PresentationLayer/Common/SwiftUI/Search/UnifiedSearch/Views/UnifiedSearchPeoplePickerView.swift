import SwiftUI
import Services

struct UnifiedSearchPersonRow: Identifiable, Hashable {
    let identity: String
    let title: String
    let icon: Icon

    var id: String { identity }
}

// The full people browse behind the People chip - pick one to filter by author.
// Rows come pre-sorted (1:1 partners in vault order first, then alphabetical).
struct UnifiedSearchPeoplePickerView: View {

    let people: [UnifiedSearchPersonRow]
    let onSelect: (UnifiedSearchPersonRow) -> Void

    @State private var searchText = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            SearchBar(text: $searchText, focused: false, shouldShowDivider: false)
            list
        }
        .background(Color.Background.secondary)
    }

    private var filteredPeople: [UnifiedSearchPersonRow] {
        guard searchText.isNotEmpty else { return people }
        return people.filter { $0.title.localizedStandardContains(searchText) }
    }

    @ViewBuilder
    private var list: some View {
        if filteredPeople.isEmpty {
            EmptyStateView(
                title: Loc.nothingFound,
                subtitle: "",
                style: .plain
            )
        } else {
            PlainList {
                ForEach(filteredPeople) { person in
                    Button {
                        dismiss()
                        onSelect(person)
                    } label: {
                        HStack(spacing: 12) {
                            IconView(icon: person.icon)
                                .frame(width: 40, height: 40)
                            AnytypeText(person.title, style: .previewTitle2Medium)
                                .foregroundStyle(Color.Text.primary)
                                .lineLimit(1)
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
