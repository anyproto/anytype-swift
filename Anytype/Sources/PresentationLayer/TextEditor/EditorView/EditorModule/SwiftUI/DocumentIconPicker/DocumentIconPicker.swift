import SwiftUI

struct DocumentIconPicker: View {

    @EnvironmentObject private var iconViewModel: DocumentIconPickerViewModel
    @Environment(\.presentationMode) private var presentationMode

    @State private var tabSelection: Tab = .emoji
    
    var body: some View {
        VStack(spacing: 0) {
            if tabSelection == .emoji {
                emojiTab
            } else if tabSelection == .upload {
                mediaPickerView
            }
            tabHeaders
        }
        .ignoresSafeArea(.keyboard)
    }
    
    private var emojiTab: some View {
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
                iconViewModel.removeIcon()
                presentationMode.wrappedValue.dismiss()
            } label: {
                AnytypeText("Remove", style: .headline)
                    .foregroundColor(.red)
            }
        }
    }
    
    private var mediaPickerView: some View {
        MediaPickerView(contentType: iconViewModel.mediaPickerContentType) { item in
            item.flatMap {
                iconViewModel.uploadImage(from: $0)
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
    
    private var tabHeaders: some View {
        HStack {
            ForEach(Tab.allCases, id: \.self) { tab in
                tabHeaderButton(tab)
            }
        }
        .frame(height: 48)
    }
    
    private func tabHeaderButton(_ tab: Tab) -> some View {
        Button {
            switch tab {
            case .random:
                EmojiProvider.shared.randomEmoji().flatMap {
                    handleSelectedEmoji($0)
                }
            default:
                UISelectionFeedbackGenerator().selectionChanged()
                withAnimation {
                    tabSelection = tab
                }
            }
            
        } label: {
            AnytypeText(tab.title, style: .headline)
                .foregroundColor(tabSelection == tab ? Color.buttonSelected : Color.buttonActive)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func handleSelectedEmoji(_ emoji: Emoji) {
        iconViewModel.setEmoji(emoji.unicode)
        presentationMode.wrappedValue.dismiss()
    }
    
}

// MARK: - Private extension

private extension DocumentIconPicker {
    
    enum Tab: CaseIterable {
        case emoji
        case random
        case upload
        
        var title: String {
            switch self {
            case .emoji: return "Emoji"
            case .random: return "Random"
            case .upload: return "Upload"
            }
        }
    }
    
}

struct DocumentIconPicker_Previews: PreviewProvider {
    static var previews: some View {
        DocumentIconPicker()
    }
}
