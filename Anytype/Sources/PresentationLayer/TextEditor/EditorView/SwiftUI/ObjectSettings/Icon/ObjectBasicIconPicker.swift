import SwiftUI

struct ObjectBasicIconPicker: View {

    @EnvironmentObject private var viewModel: ObjectIconPickerViewModel
    @Environment(\.presentationMode) private var presentationMode
    @State private var selectedTab: Tab = .emoji
        
    var body: some View {
        VStack(spacing: 0) {
            switch selectedTab {
            case .emoji:
                emojiTabView
            case .upload:
                uploadTabView
            }
            tabBarView
        }
        .ignoresSafeArea(.keyboard)
    }
    
    private var emojiTabView: some View {
        VStack(spacing: 0) {
            DragIndicator(bottomPadding: 0)
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
            AnytypeText("Change icon", style: .headlineSemibold)
                .multilineTextAlignment(.center)
        } rightButton: {
            Button {
                viewModel.removeIcon()
                presentationMode.wrappedValue.dismiss()
            } label: {
                AnytypeText("Remove", style: .headline)
                    .foregroundColor(.pureRed)
            }
        }
    }
    
    private var uploadTabView: some View {
        MediaPickerView(contentType: viewModel.mediaPickerContentType) { item in
            item.flatMap {
                viewModel.uploadImage(from: $0)
            }
            presentationMode.wrappedValue.dismiss()
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
            AnytypeText(tab.title, style: .headline)
                .foregroundColor(selectedTab == tab ? Color.buttonSelected : Color.buttonActive)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var randomEmojiButtonView: some View {
        Button {
            EmojiProvider.shared.randomEmoji().flatMap {
                handleSelectedEmoji($0)
            }
            
        } label: {
            AnytypeText("Random", style: .headline)
                .foregroundColor(Color.buttonActive)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func handleSelectedEmoji(_ emoji: Emoji) {
        viewModel.setEmoji(emoji.unicode)
        presentationMode.wrappedValue.dismiss()
    }
    
}

// MARK: - Private extension

private extension ObjectBasicIconPicker {
    
    enum BottomTabViewItem: Hashable {
        case tab(Tab)
        case randomEmojiButton
    }
    
    enum Tab {
        case emoji
        case upload
        
        var title: String {
            switch self {
            case .emoji: return "Emoji"
            case .upload: return "Upload"
            }
        }
    }
    
}

struct DocumentIconPicker_Previews: PreviewProvider {
    static var previews: some View {
        ObjectBasicIconPicker()
    }
}
