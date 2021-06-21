import SwiftUI

struct DocumentIconPicker: View {

    @EnvironmentObject private var iconViewModel: DocumentIconPickerViewModel
    @Environment(\.presentationMode) private var presentationMode

    @State private var tabSelection: IconTab = .emoji
    
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
            Button {
                UISelectionFeedbackGenerator().selectionChanged()
                withAnimation {
                    tabSelection = .emoji
                }
                
            } label: {
                AnytypeText(IconTab.emoji.title, style: .headline)
                    .foregroundColor(tabSelection == .emoji ? Color.buttonSelected : Color.buttonActive)
            }
            .frame(maxWidth: .infinity)
            
            Button {
                EmojiProvider.shared.randomEmoji().flatMap {
                    handleSelectedEmoji($0)
                }
                
            } label: {
                AnytypeText(IconTab.random.title, style: .headline)
                    .foregroundColor(Color.buttonActive)
            }
            .frame(maxWidth: .infinity)
            
            Button {
                UISelectionFeedbackGenerator().selectionChanged()
                withAnimation {
                    tabSelection = .upload
                }
                
            } label: {
                AnytypeText(IconTab.upload.title, style: .headline)
                    .foregroundColor(tabSelection == .upload ? Color.buttonSelected : Color.buttonActive)
            }
            .frame(maxWidth: .infinity)
        }
        .frame(height: 48)
    }
    
    private func handleSelectedEmoji(_ emoji: Emoji) {
        iconViewModel.setEmoji(emoji.unicode)
        presentationMode.wrappedValue.dismiss()
    }
    
}

// MARK: - Private extension

private extension DocumentIconPicker {
    
    enum IconTab {
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
