import SwiftUI

struct ObjectBasicIconPicker: View {
    let viewModel: ObjectIconPickerViewModelProtocol
    
    @Environment(\.presentationMode) private var presentationMode
    @State private var selectedTab: Tab = .emoji
    
    var onDismiss: (() -> ())?
        
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
            AnytypeText("Change icon".localized, style: .uxTitle1Semibold, color: .textPrimary)
                .multilineTextAlignment(.center)
        } rightButton: {
            if viewModel.isRemoveButtonAvailable {
                Button {
                    viewModel.removeIcon()
                    dismiss()
                } label: {
                    AnytypeText("Remove".localized, style: .uxBodyRegular, color: Color.System.red)
                }
            } else {
                EmptyView()
            }
        }
    }
    
    private var uploadTabView: some View {
        MediaPickerView(contentType: viewModel.mediaPickerContentType) { item in
            item.flatMap {
                viewModel.uploadImage(from: $0)
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
            AnytypeText(tab.title, style: .uxBodyRegular, color: selectedTab == tab ? Color.buttonSelected : Color.buttonActive)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var randomEmojiButtonView: some View {
        Button {
            EmojiProvider.shared.randomEmoji().flatMap {
                handleSelectedEmoji($0)
            }
        } label: {
            AnytypeText("Random".localized, style: .uxBodyRegular, color: .buttonActive)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func handleSelectedEmoji(_ emoji: EmojiData) {
        viewModel.setEmoji(emoji.emoji)
        dismiss()
    }
    
    private func dismiss() {
        presentationMode.wrappedValue.dismiss()
        onDismiss?()
    }
}

// MARK: - Private extension

private extension ObjectBasicIconPicker {
    enum Tab {
        case emoji
        case upload
        
        var title: String {
            switch self {
            case .emoji: return "Emoji".localized
            case .upload: return "Upload".localized
            }
        }
    }
}
