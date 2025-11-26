import SwiftUI


struct EmojiGridView: View {

    let onEmojiSelect: (EmojiData) -> ()

    @State private var searchText = ""
    @State private var filteredEmojis: [EmojiData] = []

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
            updateFilteredEmojis()
        }
        .onChange(of: searchText) {
            updateFilteredEmojis()
        }
    }

    private var contentView: some View {
        Group {
            if filteredEmojis.isEmpty {
                makeEmptySearchResultView(placeholder: searchText)
            } else {
                makeEmojiGrid(emojis: filteredEmojis)
            }
        }
    }

    private func updateFilteredEmojis() {
        let groups = EmojiProvider.shared.filteredEmojiGroups(keyword: searchText)
        filteredEmojis = groups.flatMap { $0.emojis }
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
    
    private func makeEmojiGrid(emojis: [EmojiData]) -> some View {
        ScrollView(showsIndicators: false) {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(emojis.indices, id: \.self) { index in
                    Button {
                        emojis[safe: index].flatMap {
                            onEmojiSelect($0)
                        }
                    } label: {
                        emojis[safe: index].map { emoji in
                            Text(verbatim: emoji.emoji)
                                .font(.system(size: 40))
                        }
                    }
                }
            }
            .padding(.top, 12)
        }
        .scrollDismissesKeyboard(.interactively)
        .padding(.horizontal, 16)
    }
    
}

struct EmojiGridView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiGridView(onEmojiSelect: { _ in })
    }
}
