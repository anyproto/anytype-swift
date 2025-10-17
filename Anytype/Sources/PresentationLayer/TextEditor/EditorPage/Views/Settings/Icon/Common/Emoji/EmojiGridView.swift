import SwiftUI


struct EmojiGridView: View {

    let onEmojiSelect: (EmojiData) -> ()

    @State private var searchText = ""
    @State private var filteredGroups: [EmojiGroup] = []

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack(spacing: 0) {
            SearchBar(text: $searchText, focused: false)
            contentView
        }
        .onAppear {
            updateFilteredGroups()
        }
        .onChange(of: searchText) {
            updateFilteredGroups()
        }
    }

    // MARK: - Private variables

    private var contentView: some View {
        Group {
            if filteredGroups.isEmpty {
                makeEmptySearchResultView(placeholder: searchText)
            } else if filteredGroups.haveFewEmoji {
                makeEmojiGrid(groups: filteredGroups.flattenedList)
            } else {
                makeEmojiGrid(groups: filteredGroups)
            }
        }
    }

    private func updateFilteredGroups() {
        filteredGroups = EmojiProvider.shared.filteredEmojiGroups(keyword: searchText)
    }
    
    private func makeEmptySearchResultView(placeholder: String) -> some View {
        VStack(spacing: 0) {
            AnytypeText(
                Loc.thereIsNoEmojiNamed + " \"\(placeholder)\"",
                style: .uxBodyRegular
            )
            .foregroundColor(.Text.primary)
            .multilineTextAlignment(.center)
            
            AnytypeText(
                Loc.tryToFindANewOneOrUploadYourImage,
                style: .uxBodyRegular
            )
            .foregroundColor(.Text.secondary)
            .multilineTextAlignment(.center)
            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }
    
    private func makeEmojiGrid(groups: [EmojiGroup]) -> some View {
        ScrollView(showsIndicators: false) {
            makeGridView(groups: groups)
        }
        .scrollDismissesKeyboard(.interactively)
        .padding(.horizontal, 16)
    }
    
    private func makeGridView(groups: [EmojiGroup]) -> some View {
        LazyVGrid(
            columns: columns,
            spacing: 0
        ) {
            ForEach(groups, id: \.name) { group in
                Section(header: sectionHeader(with: group.name)) {
                    ForEach(group.emojis.indices, id: \.self) { index in
                        Button {
                            group.emojis[safe: index].flatMap {
                                onEmojiSelect($0)
                            }
                        } label: {
                            emojiGridView(at: index, inEmojis: group.emojis)
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func sectionHeader(with name: String) -> some View {
        if name.isNotEmpty {
            VStack(spacing: 0) {
                PickerSectionHeaderView(title: name)
                Spacer.fixedHeight(15)
            }
        } else {
            Spacer.fixedHeight(12)
        }
    }
    
    private func emojiGridView(at index: Int, inEmojis emojis: [EmojiData]) -> some View {
        emojis[safe: index].flatMap { emoji in
            Text(verbatim: emoji.emoji)
                .font(.system(size: 40))
                .if(index > columns.count - 1) {
                    $0.padding(.top, 12)
                }
        }
    }
    
}

struct EmojiGridView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiGridView(onEmojiSelect: { _ in })
    }
}
