
import SwiftUI

struct EmojiGridView: View {
    
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
                style: .headline
            )
            .multilineTextAlignment(.center)
            
            AnytypeText(
                "Try to find a new one or upload your image",
                style: .headline
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
            LazyVGrid(
                columns: columns,
                spacing: 10,
                pinnedViews: [.sectionHeaders]
            ) {
                    ForEach(groups, id: \.name) { group in
                        Section(
                            header: makeSectionView(title: group.name)
                        ) {
                            ForEach(group.emojis, id: \.unicode) { emoji in
                                Text(emoji.unicode)
                                    .font(.system(size: 40))
                            }
                        }
                    }
                }
        }.gesture(
            DragGesture().onChanged { _ in
                UIApplication.shared.sendAction(
                    #selector(UIResponder.resignFirstResponder),
                    to: nil,
                    from: nil,
                    for: nil
                )
            }
        )
        .padding(.horizontal, 16)
    }
    
    private func makeSectionView(title: String) -> some View {
        HStack {
            Spacer()
            AnytypeText(
                title,
                style: .captionMedium
            )
            .foregroundColor(Color.textSecondary)
            Spacer()
        }
        .padding(.top, 18)
        .padding(.bottom, 12)
        .background(Color.background)
    }
    
}

struct EmojiGridView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiGridView()
    }
}
