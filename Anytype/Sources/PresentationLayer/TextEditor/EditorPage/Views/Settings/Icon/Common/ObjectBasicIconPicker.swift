import SwiftUI


struct ObjectBasicIconPicker: View {
    
    let isRemoveButtonAvailable: Bool
    let mediaPickerContentType: MediaPickerContentType
    let onSelectItemProvider: (_ itemProvider: NSItemProvider) -> Void
    let onSelectEmoji: (_ emoji: EmojiData) -> Void
    let removeIcon: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab: Tab = .emoji
    
    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $selectedTab) {
                emojiTabView
                    .tag(Tab.emoji)
                uploadTabView
                    .tag(Tab.upload)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            tabBarView
        }
        .ignoresSafeArea(.keyboard)
        .background(Color.Background.primary)
    }
    
    private var emojiTabView: some View {
        VStack(spacing: 0) {
            DragIndicator()
            navigationBarView
            EmojiGridView { emoji in
                handleSelectedEmoji(emoji)
            }
        }
        .transition(
            .asymmetric(
                insertion: .move(edge: .leading),
                removal: .move(edge: .trailing)
            )
        )
    }
    
    private var navigationBarView: some View {
        InlineNavigationBar {
            AnytypeText(Loc.changeIcon, style: .uxTitle1Semibold)
                .foregroundColor(.Text.primary)
                .multilineTextAlignment(.center)
        } rightButton: {
            if isRemoveButtonAvailable {
                Button {
                    removeIcon()
                    dismiss()
                } label: {
                    AnytypeText(Loc.remove, style: .uxBodyRegular)
                        .foregroundColor(.Pure.red)
                }
            } else {
                EmptyView()
            }
        }
    }
    
    private var uploadTabView: some View {
        MediaPickerView(contentType: mediaPickerContentType) { itemProvider in
            itemProvider.flatMap {
                onSelectItemProvider($0)
            }
            dismiss()
        }
        .transition(
            .asymmetric(
                insertion: .move(edge: .trailing),
                removal: .move(edge: .leading)
            )
        )
    }
    
    private var tabBarView: some View {
        HStack {
            viewForTab(.emoji)
            randomEmojiButtonView
            viewForTab(.upload)
        }
        .frame(height: 48)
    }
    
    private func viewForTab(_ tab: Tab) -> some View {
        Button {
            UISelectionFeedbackGenerator().selectionChanged()
            withAnimation {
                selectedTab = tab
            }
            
        } label: {
            AnytypeText(tab.title, style: .uxBodyRegular)
                .foregroundColor(selectedTab == tab ? Color.Control.button : Color.Control.active)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var randomEmojiButtonView: some View {
        Button {
            EmojiProvider.shared.randomEmoji().flatMap {
                handleSelectedEmoji($0)
            }
        } label: {
            AnytypeText(Loc.random, style: .uxBodyRegular)
                .foregroundColor(.Control.active)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func handleSelectedEmoji(_ emoji: EmojiData) {
        onSelectEmoji(emoji)
        dismiss()
    }
}

// MARK: - Private extension

private extension ObjectBasicIconPicker {
    enum Tab: Int {
        case emoji
        case upload
        
        var title: String {
            switch self {
            case .emoji: return Loc.emoji
            case .upload: return Loc.upload
            }
        }
    }
}
