
import SwiftUI

struct EmojiGridView: View {
    
    let onEmojiSelect: (EmojiData) -> ()
    
    @State private var searchText = ""
    
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
    }
    
    // MARK: - Private variables
    
    private var contentView: some View {
        let filteredEmojiGroup = EmojiProvider.shared.filteredEmojiGroups(keyword: searchText)
        
        return Group {
            if filteredEmojiGroup.isEmpty {
                makeEmptySearchResultView(placeholder: searchText)
            } else if filteredEmojiGroup.haveFewEmoji {
                makeEmojiGrid(groups: filteredEmojiGroup.flattenedList)
            } else {
                makeEmojiGrid(groups: filteredEmojiGroup)
            }
        }
    }
    
    private func makeEmptySearchResultView(placeholder: String) -> some View {
        VStack(spacing: 0) {
            AnytypeText(
                Loc.thereIsNoEmojiNamed + " \"\(placeholder)\"",
                style: .uxBodyRegular,
                color: .Text.primary
            )
            .multilineTextAlignment(.center)
            
            AnytypeText(
                Loc.tryToFindANewOneOrUploadYourImage,
                style: .uxBodyRegular,
                color: .Text.secondary
            )
            .multilineTextAlignment(.center)
            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }
    
    private func makeEmojiGrid(groups: [EmojiGroup]) -> some View {
        ScrollView(showsIndicators: false) {
            makeGridView(groups: groups)
        }.gesture(
            DragGesture().onChanged { _ in
                UIApplication.shared.hideKeyboard()
            }
        )
        .padding(.horizontal, 16)
    }
    
    private func makeGridView(groups: [EmojiGroup]) -> some View {
        LazyVGrid(
            columns: columns,
            spacing: 0,
            pinnedViews: [.sectionHeaders]
        ) {
            ForEach(groups, id: \.name) { group in
                Section(header: PickerSectionHeaderView(title: group.name)) {
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
    
    private func emojiGridView(at index: Int, inEmojis emojis: [EmojiData]) -> some View {
        emojis[safe: index].flatMap { emoji in
            Text(emoji.emoji)
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
