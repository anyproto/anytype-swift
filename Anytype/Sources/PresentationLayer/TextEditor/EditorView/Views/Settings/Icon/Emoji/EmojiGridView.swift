
import SwiftUI

struct EmojiGridView: View {
    
    let onEmojiSelect: (Emoji) -> ()
    
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
            SearchBar(text: $searchText)
            contentView
        }
    }
    
    // MARK: - Private variables
    
    private var contentView: some View {
        let filteredEmojiGroup = EmojiProvider.shared.filteredEmojiGroups(keyword: searchText)
        
        return Group {
            if filteredEmojiGroup.isEmpty {
                makeEmptySearchResultView(placeholder: searchText)
            } else {
                makeEmojiGrid(groups: filteredEmojiGroup)
            }
        }
    }
    
    private func makeEmptySearchResultView(placeholder: String) -> some View {
        VStack {
            // TODO: - fix localisation. it does not work now
            AnytypeText(
                "There is no emoji named" + " \"\(placeholder)\"",
                style: .uxBodyRegular
            )
            .multilineTextAlignment(.center)
            
            AnytypeText(
                "Try to find a new one or upload your image",
                style: .uxBodyRegular
            )
            .foregroundColor(Color.textSecondary)
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
            spacing: 12,
            pinnedViews: [.sectionHeaders]
        ) {
                ForEach(groups, id: \.name) { group in
                    Section(header: PickerSectionHeaderView(title: group.name)) {
                        ForEach(group.emojis, id: \.unicode) { emoji in
                            Button {
                                onEmojiSelect(emoji)
                            } label: {
                                Text(emoji.unicode).font(.system(size: 40))
                            }
                        }
                    }
                }
            }
    }
    
}

struct EmojiGridView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiGridView(onEmojiSelect: { _ in })
    }
}
